-- Clustered index (not on primary key)
CREATE CLUSTERED INDEX idx_iot_device_readings_peripheral_id_clustered
ON iot_device_readings (peripheral_id);

-- Nonclustered index
CREATE NONCLUSTERED INDEX idx_iot_device_readings_connection_type
ON iot_device_readings (connection_type);

-- Multicolumn nonclustered index
CREATE NONCLUSTERED INDEX idx_iot_device_readings_peripheralid_timestamp
ON iot_device_readings (peripheral_id, unix_timestamp);

-- Multicolumn nonclustered index with INCLUDE 
CREATE NONCLUSTERED INDEX idx_iot_device_readings_peripheralid_timestamp_include_temp
ON iot_device_readings (peripheral_id, unix_timestamp)
INCLUDE (internal_temperature, external_temperature);

-- Filtered index
CREATE NONCLUSTERED INDEX idx_iot_device_readings_status_event
ON iot_device_readings (peripheral_status)
WHERE peripheral_status = 1;

-- Columnstore index
CREATE NONCLUSTERED COLUMNSTORE INDEX idx_iot_device_readings_columnstore
ON iot_device_readings (
    peripheral_id,
    battery_voltage,
    internal_temperature,
    external_temperature,
    acceleration_x,
    acceleration_y,
    acceleration_z
);
