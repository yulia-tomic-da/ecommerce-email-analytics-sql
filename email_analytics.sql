-- Calculate account metrics: unique accounts count by date, country, and account characteristics
WITH account_metrics AS (
  SELECT
    s.date AS date,
    sp.country AS country,
    a.send_interval AS send_interval,
    a.is_verified AS is_verified,
    a.is_unsubscribed AS is_unsubscribed,
    COUNT(DISTINCT a.id) AS account_cnt,
    0 AS sent_msg,
    0 AS open_msg,
    0 AS visit_msg
  FROM `DA.account` a
  JOIN `DA.account_session` acs
    ON a.id = acs.account_id
  JOIN `DA.session` s
    ON acs.ga_session_id = s.ga_session_id
  JOIN `DA.session_params` sp
    ON s.ga_session_id = sp.ga_session_id
  GROUP BY 1, 2, 3, 4, 5
),

-- Calculate email metrics: count of sent, opened, and visited emails
email_metrics AS (
  SELECT
    DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
    CAST(sp.country AS STRING) AS country,
    a.send_interval AS send_interval,
    a.is_verified AS is_verified,
    a.is_unsubscribed AS is_unsubscribed,
    0 AS account_cnt,
    COUNT(DISTINCT es.id_message) AS sent_msg,
    COUNT(DISTINCT eo.id_message) AS open_msg,
    COUNT(DISTINCT ev.id_message) AS visit_msg
  FROM `DA.email_sent` es
  JOIN `DA.account` a
    ON es.id_account = a.id
  LEFT JOIN `DA.email_open` eo
    ON es.id_message = eo.id_message
  LEFT JOIN `DA.email_visit` ev
    ON es.id_message = ev.id_message
  JOIN `DA.account_session` acs
    ON es.id_account = acs.account_id
  JOIN `DA.session` s
    ON acs.ga_session_id = s.ga_session_id
  JOIN `DA.session_params` sp
    ON s.ga_session_id = sp.ga_session_id
  GROUP BY
    s.date,
    es.sent_date,
    sp.country,
    a.send_interval,
    a.is_verified,
    a.is_unsubscribed
),

-- Combine both datasets into a single table
combined_date_metrics AS (
  SELECT * FROM account_metrics
  UNION ALL
  SELECT * FROM email_metrics
),

-- Aggregate combined metrics
aggregated_metrics AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    SUM(account_cnt) AS account_cnt,
    SUM(sent_msg) AS sent_msg,
    SUM(open_msg) AS open_msg,
    SUM(visit_msg) AS visit_msg
  FROM combined_date_metrics
  GROUP BY date, country, send_interval, is_verified, is_unsubscribed
),

-- Calculate total country-level aggregations
ranked_metrics AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    sent_msg,
    open_msg,
    visit_msg,
    -- Total accounts by country
    SUM(account_cnt) OVER (PARTITION BY country) AS total_country_account_cnt,
    -- Total sent emails by country
    SUM(sent_msg) OVER (PARTITION BY country) AS total_country_sent_cnt
  FROM aggregated_metrics
),

-- Rank countries using window functions
full_ranked_metrics AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    sent_msg,
    open_msg,
    visit_msg,
    total_country_account_cnt,
    total_country_sent_cnt,
    -- Country rank by accounts count
    DENSE_RANK() OVER (ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
    -- Country rank by sent emails count
    DENSE_RANK() OVER (ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
  FROM ranked_metrics
)

-- Final query: Filter results to top 10 countries
SELECT *
FROM full_ranked_metrics
WHERE rank_total_country_account_cnt <= 10 
   OR rank_total_country_sent_cnt <= 10;
