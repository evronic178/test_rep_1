WITH settings AS (
  SELECT
    -- Извлекаем значения в байтах
    (SELECT setting::bigint * CASE unit
        WHEN 'kB' THEN 1024
        WHEN 'MB' THEN 1024*1024
        WHEN 'GB' THEN 1024*1024*1024
        WHEN '8kB' THEN 8192
        ELSE 1 END
     FROM pg_settings WHERE name = 'shared_buffers') AS shared_buffers_bytes,

    (SELECT setting::bigint * CASE unit
        WHEN 'kB' THEN 1024
        WHEN 'MB' THEN 1024*1024
        WHEN 'GB' THEN 1024*1024*1024
        ELSE 1 END
     FROM pg_settings WHERE name = 'work_mem') AS work_mem_bytes,

    (SELECT setting::bigint * CASE unit
        WHEN 'kB' THEN 1024
        WHEN 'MB' THEN 1024*1024
        WHEN 'GB' THEN 1024*1024*1024
        ELSE 1 END
     FROM pg_settings WHERE name = 'maintenance_work_mem') AS maintenance_work_mem_bytes,

    (SELECT setting::int FROM pg_settings WHERE name = 'max_connections') AS max_connections
)

SELECT
  pg_size_pretty(shared_buffers_bytes) AS shared_buffers,
  pg_size_pretty(work_mem_bytes) AS work_mem_per_op,
  pg_size_pretty(maintenance_work_mem_bytes) AS maintenance_work_mem_per_session,
  max_connections,
  
  -- Примерная оценка: shared_buffers + work_mem * 2 * max_connections
  pg_size_pretty(
    shared_buffers_bytes + (work_mem_bytes * max_connections * 2)
  ) AS estimated_total_memory_usage
FROM settings;
