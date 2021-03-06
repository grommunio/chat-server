SET @preparedStatement = (SELECT IF(
    (
        SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
        WHERE table_name = 'Threads'
        AND table_schema = DATABASE()
        AND index_name = 'idx_threads_channel_id'
    ) > 0,
    'SELECT 1',
    'CREATE INDEX idx_threads_channel_id ON Threads(ChannelId);'
));

PREPARE createIndexIfNotExists FROM @preparedStatement;
EXECUTE createIndexIfNotExists;
DEALLOCATE PREPARE createIndexIfNotExists;

SET @preparedStatement = (SELECT IF(
    (
        SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
        WHERE table_name = 'Threads'
        AND table_schema = DATABASE()
        AND index_name = 'idx_threads_channel_id_last_reply_at'
    ) > 0,
    'DROP INDEX idx_threads_channel_id_last_reply_at ON Threads;',
    'SELECT 1'
));

PREPARE removeIndexIfExists FROM @preparedStatement;
EXECUTE removeIndexIfExists;
DEALLOCATE PREPARE removeIndexIfExists;

SET @preparedStatement = (SELECT IF(
    (
        SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
        WHERE table_name = 'Threads'
        AND table_schema = DATABASE()
        AND column_name = 'Participants'
        AND column_type != 'text'
    ) > 0,
    'ALTER TABLE Threads MODIFY COLUMN Participants text;',
    'SELECT 1'
));

PREPARE alterIfExists FROM @preparedStatement;
EXECUTE alterIfExists;
DEALLOCATE PREPARE alterIfExists;
