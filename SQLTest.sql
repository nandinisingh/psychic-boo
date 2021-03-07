SELECT
    client_id
    , MAX(amount) OVER(PARTITION BY client_id) AS max_eod_balance
FROM
(
    SELECT
        client_id
        , DATE(date) AS date
        , COALESCE(SUM(CASE WHEN balance_change_type = 'd' THEN (-1 * amount) ELSE amount END),0) AS amount
    FROM
        cards c
    LEFT JOIN
        transactions t
    ON
       c.card_id = t.card_id
    WHERE
        CASE
            -- not the current month
            WHEN EXTRACT(YEAR_MONTH FROM card_order_date) <> EXTRACT(YEAR_MONTH FROM CURDATE()) THEN client_id END
        -- last month only, from the current date
        AND YEAR(date) = YEAR(CURRENT_DATE - INTERVAL 1 MONTH)
        AND MONTH(date) = MONTH(CURRENT_DATE - INTERVAL 1 MONTH)
    GROUP BY
        1,2
) x