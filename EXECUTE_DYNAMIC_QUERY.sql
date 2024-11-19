CREATE OR REPLACE PROCEDURE ssdx_eng.p_EXECUTE_DYNAMIC_QUERY(
    IN p_business_rule_message_info_id INTEGER
)
LANGUAGE 'plpgsql'
AS $$
DECLARE
    dynamic_sql TEXT;
    p_table_name TEXT;
BEGIN
    -- Dynamically set the table name
    p_table_name := 'SSDX_TMP.QUERY_DATA_' || p_business_rule_message_info_id;
	
	EXECUTE 'DROP TABLE IF EXISTS ' || p_table_name; 
    -- Generate the dynamic SQL query
    WITH json_data AS (
        SELECT BSN_RULE_QUERY_RESULT::jsonb AS json_data
        FROM SUITEDBA.br_business_rule_message_info
        WHERE BUSINESS_RULE_MESSAGE_INFO_ID = p_business_rule_message_info_id
        LIMIT 1
    ),
    array_elements AS (
        -- Extract array elements
        SELECT jsonb_array_elements(json_data) AS element
        FROM json_data
    ),
    column_names AS (
        -- Extract object keys from one element (assuming all elements share the same keys)
        SELECT DISTINCT jsonb_object_keys(element) AS column_name
        FROM array_elements
    ),
    select_columns AS (
        -- Build SELECT clause for each column
        SELECT 
            '  (jsonb_array_elements(BSN_RULE_QUERY_RESULT)->>''' || column_name || ''') AS "' || column_name || '" ' AS column_select
        FROM column_names
    ),
    final_query AS (
        SELECT
            'CREATE TABLE ' || p_table_name || ' AS SELECT ' || STRING_AGG(column_select, ', ') || 
            ' FROM SUITEDBA.br_business_rule_message_info WHERE BUSINESS_RULE_MESSAGE_INFO_ID = ' || p_business_rule_message_info_id AS dynamic_sql_1
        FROM select_columns
    )
    -- Assign the final dynamically generated SQL query to the variable
    SELECT dynamic_sql_1 INTO dynamic_sql
    FROM final_query;

    -- Execute the dynamically generated SQL query
    EXECUTE dynamic_sql;

    -- Optional: Log success message
    RAISE NOTICE 'Table % created successfully with query: %', p_table_name, dynamic_sql;

END;
$$;
