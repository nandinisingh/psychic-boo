WITH filtered_clients AS (
    SELECT
        client_id
        , card_id
    FROM
        cards
    WHERE
        CASE
            -- not the current month
            WHEN EXTRACT(YEAR_MONTH FROM card_order_date) <> EXTRACT(YEAR_MONTH FROM CURDATE()) THEN client_id END
),


SELECT
    client_id
    , MAX(amount) OVER(PARTITION BY client_id) AS max_eod_balance
FROM
(
    SELECT
        client_id
        , EXTRACT(DATE FROM date) AS date
        , COALESCE(SUM(CASE WHEN(balance_change_type = 'd' THEN (-1 * amount) ELSE amount END)),0) AS amount
    FROM
        filtered_clients c
    LEFT JOIN
        transactions t
    ON
       c.card_id = t.card_id
    WHERE
        -- last month only, from the current date
        YEAR(date) = YEAR(CURRENT_DATE - INTERVAL 1 MONTH)
        AND MONTH(date) = MONTH(CURRENT_DATE - INTERVAL 1 MONTH)
    GROUP BY
        1,2
) x
