CREATE TABLE iot_device_readings (
    id BIGINT NOT NULL,
    unix_timestamp BIGINT NOT NULL,
    peripheral_id INT NOT NULL,
    connection_type INT NOT NULL,
    peripheral_status INT NOT NULL,
    firmware_version INT NOT NULL,
    packet_counter INT NOT NULL,
    battery_voltage FLOAT NOT NULL,
    internal_temperature FLOAT NOT NULL,
    external_temperature FLOAT NOT NULL,
    acceleration_x FLOAT NOT NULL,
    acceleration_y FLOAT NOT NULL,
    acceleration_z FLOAT NOT NULL,
    pressure FLOAT NOT NULL,
    humidity FLOAT NOT NULL,
    tension FLOAT NOT NULL
);

-- Insert 1,000,000 random records
WITH iterator_cte(number) AS (
    SELECT
        1 number

    UNION ALL

    SELECT
        number + 1
    FROM iterator_cte
    WHERE
        number < 1000000
)
INSERT INTO iot_device_readings (
    id,
    unix_timestamp,
    peripheral_id,
    connection_type,
    peripheral_status,
    firmware_version,
    packet_counter,
    battery_voltage,
    internal_temperature,
    external_temperature,
    acceleration_x,
    acceleration_y,
    acceleration_z,
    pressure,
    humidity,
    tension
)
SELECT
    -- ID
    CTE.number,
    -- Random timestamp from the last month
    CAST(
        DATEADD(
            DAY,
            - CAST(
                ABS(CHECKSUM(NEWID())) / 2147483647.0 * 30 AS INT
            ),
            GETDATE()
        ) + DATEADD(
            SECOND,
            CAST(
                ABS(CHECKSUM(NEWID())) / 2147483647.0 * 86400 AS INT
            ),
            0
        ) AS BIGINT
    ),
    -- Random peripheral_id
    FLOOR(ABS(CHECKSUM(NEWID())) / 2147483647.0 * 101) + 1,
    -- Random connection_type
    CAST(FLOOR(ABS(CHECKSUM(NEWID())) / 2147483647.0 * 2) AS INT),
    -- Random status
    CAST(FLOOR(ABS(CHECKSUM(NEWID())) / 2147483647.0 * 3) AS INT),
    -- Random firmware_version
    FLOOR(ABS(CHECKSUM(NEWID())) / 2147483647.0 * 10) + 1,
    -- Random packet_counter (1-255)
    FLOOR(ABS(CHECKSUM(NEWID())) / 2147483647.0 * 255) + 1,
    -- Random battery_voltage (2.5-4.2V)
    ROUND(ABS(CHECKSUM(NEWID())) / 2147483647.0 * (4.2 - 2.5) + 2.5, 2),
    -- Random internal_temperature (-10 to 60)
    ROUND(ABS(CHECKSUM(NEWID())) / 2147483647.0 * 70 - 10, 2),
    -- Random external_temperature (-20 to 50)
    ROUND(ABS(CHECKSUM(NEWID())) / 2147483647.0 * 70 - 20, 2),
    -- Random acceleration_x/y/z (-10 to 10)
    ROUND(ABS(CHECKSUM(NEWID())) / 2147483647.0 * 20 - 10, 3),
    ROUND(ABS(CHECKSUM(NEWID())) / 2147483647.0 * 20 - 10, 3),
    ROUND(ABS(CHECKSUM(NEWID())) / 2147483647.0 * 20 - 10, 3),
    -- Random pressure (950-1050 hPa)
    ROUND(ABS(CHECKSUM(NEWID())) / 2147483647.0 * 100 + 950, 2),
    -- Random humidity (0-100%)
    ROUND(ABS(CHECKSUM(NEWID())) / 2147483647.0 * 100, 2),
    -- Random tension (0-100)
    ROUND(ABS(CHECKSUM(NEWID())) / 2147483647.0 * 100, 2)
FROM iterator_cte CTE OPTION (MAXRECURSION 0);