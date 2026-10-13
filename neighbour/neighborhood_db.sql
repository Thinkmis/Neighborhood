-- =====================================================
--  Neighborhood Platform - MySQL Database Schema
--  Requires MySQL 8.0.16+ (CHECK constraints)
-- =====================================================

DROP DATABASE IF EXISTS neighborhood_db;
CREATE DATABASE neighborhood_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE neighborhood_db;

-- -----------------------------------------------------
-- 1. Roles
-- -----------------------------------------------------
CREATE TABLE roles (
  role_id     TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_name   VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 2. Neighborhoods (community / area)
-- -----------------------------------------------------
CREATE TABLE neighborhoods (
  neighborhood_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(120) NOT NULL,
  area            VARCHAR(120),
  city            VARCHAR(80),
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_neighborhood (name, city)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 3. Users
-- -----------------------------------------------------
CREATE TABLE users (
  user_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_id         TINYINT UNSIGNED NOT NULL,
  neighborhood_id INT UNSIGNED NULL,
  full_name       VARCHAR(100) NOT NULL,
  username        VARCHAR(50)  NOT NULL UNIQUE,
  email           VARCHAR(120) NOT NULL UNIQUE,
  phone           VARCHAR(20),
  password_hash   VARCHAR(255) NOT NULL,
  status          ENUM('active','suspended','banned') NOT NULL DEFAULT 'active',
  last_login_at   DATETIME NULL,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(role_id),
  CONSTRAINT fk_users_neighborhood FOREIGN KEY (neighborhood_id)
    REFERENCES neighborhoods(neighborhood_id) ON DELETE SET NULL,
  INDEX idx_users_role (role_id),
  INDEX idx_users_neighborhood (neighborhood_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 4. User Profiles
-- -----------------------------------------------------
CREATE TABLE user_profiles (
  profile_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id       INT UNSIGNED NOT NULL UNIQUE,
  address       VARCHAR(255),
  bio           TEXT,
  profile_image VARCHAR(255),
  date_of_birth DATE NULL,
  gender        ENUM('male','female','other') NULL,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_profile_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 5. Post Categories
-- -----------------------------------------------------
CREATE TABLE post_categories (
  category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 6. Posts & Announcements
-- -----------------------------------------------------
CREATE TABLE posts (
  post_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  neighborhood_id INT UNSIGNED NULL,
  category_id     INT UNSIGNED NULL,
  post_type       ENUM('post','announcement') NOT NULL DEFAULT 'post',
  title           VARCHAR(200) NOT NULL,
  description     TEXT NOT NULL,
  image_url       VARCHAR(255),
  status          ENUM('published','hidden','deleted') NOT NULL DEFAULT 'published',
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_posts_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_posts_neighborhood FOREIGN KEY (neighborhood_id)
    REFERENCES neighborhoods(neighborhood_id) ON DELETE SET NULL,
  CONSTRAINT fk_posts_category FOREIGN KEY (category_id)
    REFERENCES post_categories(category_id) ON DELETE SET NULL,
  INDEX idx_posts_feed (status, created_at),
  INDEX idx_posts_user (user_id),
  INDEX idx_posts_neighborhood (neighborhood_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 7. Community Events
-- -----------------------------------------------------
CREATE TABLE events (
  event_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  created_by       INT UNSIGNED NOT NULL,
  neighborhood_id  INT UNSIGNED NULL,
  title            VARCHAR(200) NOT NULL,
  description      TEXT NOT NULL,
  event_date       DATE NOT NULL,
  event_time       TIME NOT NULL,
  location         VARCHAR(255) NOT NULL,
  image_url        VARCHAR(255),
  max_participants INT UNSIGNED NULL,
  status           ENUM('upcoming','ongoing','completed','cancelled') NOT NULL DEFAULT 'upcoming',
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_events_user FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_events_neighborhood FOREIGN KEY (neighborhood_id)
    REFERENCES neighborhoods(neighborhood_id) ON DELETE SET NULL,
  INDEX idx_events_date (event_date, status)
) ENGINE=InnoDB;

CREATE TABLE event_participants (
  event_id  INT UNSIGNED NOT NULL,
  user_id   INT UNSIGNED NOT NULL,
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (event_id, user_id),
  CONSTRAINT fk_ep_event FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
  CONSTRAINT fk_ep_user  FOREIGN KEY (user_id)  REFERENCES users(user_id)  ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 8. Help & Support Requests
-- -----------------------------------------------------
CREATE TABLE help_requests (
  help_request_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  neighborhood_id INT UNSIGNED NULL,
  help_type       ENUM('medical','grocery','repair','transport','childcare','elderly_care','other') NOT NULL,
  title           VARCHAR(200) NOT NULL,
  details         TEXT NOT NULL,
  status          ENUM('open','in_progress','resolved','closed') NOT NULL DEFAULT 'open',
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_help_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_help_neighborhood FOREIGN KEY (neighborhood_id)
    REFERENCES neighborhoods(neighborhood_id) ON DELETE SET NULL,
  INDEX idx_help_status (status, created_at)
) ENGINE=InnoDB;

CREATE TABLE help_responses (
  response_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  help_request_id INT UNSIGNED NOT NULL,
  responder_id    INT UNSIGNED NOT NULL,
  message         TEXT NOT NULL,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_hr_request   FOREIGN KEY (help_request_id) REFERENCES help_requests(help_request_id) ON DELETE CASCADE,
  CONSTRAINT fk_hr_responder FOREIGN KEY (responder_id)    REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_hr_request (help_request_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 9. Local Service Directory
-- -----------------------------------------------------
CREATE TABLE service_categories (
  service_category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name                VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE services (
  service_id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  provider_id         INT UNSIGNED NOT NULL,
  neighborhood_id     INT UNSIGNED NULL,
  service_category_id INT UNSIGNED NOT NULL,
  service_name        VARCHAR(150) NOT NULL,
  description         TEXT NOT NULL,
  contact_phone       VARCHAR(20) NOT NULL,
  contact_email       VARCHAR(120),
  price_info          VARCHAR(100),
  is_active           BOOLEAN NOT NULL DEFAULT TRUE,
  created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_srv_provider FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_srv_neighborhood FOREIGN KEY (neighborhood_id)
    REFERENCES neighborhoods(neighborhood_id) ON DELETE SET NULL,
  CONSTRAINT fk_srv_category FOREIGN KEY (service_category_id)
    REFERENCES service_categories(service_category_id),
  INDEX idx_srv_category (service_category_id),
  FULLTEXT KEY ft_srv_search (service_name, description)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 10. Buy / Sell / Exchange Listings
-- -----------------------------------------------------
CREATE TABLE marketplace_listings (
  listing_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  neighborhood_id INT UNSIGNED NULL,
  listing_type    ENUM('sell','buy','exchange') NOT NULL,
  title           VARCHAR(200) NOT NULL,
  description     TEXT NOT NULL,
  item_condition  ENUM('new','like_new','used','for_parts') NULL,
  price           DECIMAL(10,2) NULL,
  image_url       VARCHAR(255),
  contact_info    VARCHAR(120),
  status          ENUM('available','reserved','sold','closed') NOT NULL DEFAULT 'available',
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ml_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_ml_neighborhood FOREIGN KEY (neighborhood_id)
    REFERENCES neighborhoods(neighborhood_id) ON DELETE SET NULL,
  CONSTRAINT chk_ml_price CHECK (price IS NULL OR price >= 0),
  INDEX idx_ml_type_status (listing_type, status)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 11. Lost & Found
-- -----------------------------------------------------
CREATE TABLE lost_found_items (
  item_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  neighborhood_id INT UNSIGNED NULL,
  report_type     ENUM('lost','found') NOT NULL,
  item_name       VARCHAR(150) NOT NULL,
  description     TEXT NOT NULL,
  location        VARCHAR(255) NOT NULL,
  date_occurred   DATE NULL,
  image_url       VARCHAR(255),
  contact_info    VARCHAR(120),
  status          ENUM('open','resolved') NOT NULL DEFAULT 'open',
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_lf_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_lf_neighborhood FOREIGN KEY (neighborhood_id)
    REFERENCES neighborhoods(neighborhood_id) ON DELETE SET NULL,
  INDEX idx_lf_type_status (report_type, status)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 12. Emergency Alerts
-- -----------------------------------------------------
CREATE TABLE emergency_alerts (
  alert_id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  created_by      INT UNSIGNED NOT NULL,
  neighborhood_id INT UNSIGNED NULL,
  title           VARCHAR(200) NOT NULL,
  message         TEXT NOT NULL,
  severity        ENUM('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  status          ENUM('active','resolved','expired') NOT NULL DEFAULT 'active',
  expires_at      DATETIME NULL,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_alert_user FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_alert_neighborhood FOREIGN KEY (neighborhood_id)
    REFERENCES neighborhoods(neighborhood_id) ON DELETE SET NULL,
  INDEX idx_alert_active (status, created_at)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 13. Comments (exactly one target per comment)
-- -----------------------------------------------------
CREATE TABLE comments (
  comment_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  post_id         INT UNSIGNED NULL,
  event_id        INT UNSIGNED NULL,
  help_request_id INT UNSIGNED NULL,
  listing_id      INT UNSIGNED NULL,
  lost_found_id   INT UNSIGNED NULL,
  content         TEXT NOT NULL,
  status          ENUM('visible','hidden','deleted') NOT NULL DEFAULT 'visible',
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_cm_user  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_cm_post  FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
  CONSTRAINT fk_cm_event FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
  CONSTRAINT fk_cm_help  FOREIGN KEY (help_request_id) REFERENCES help_requests(help_request_id) ON DELETE CASCADE,
  CONSTRAINT fk_cm_list  FOREIGN KEY (listing_id) REFERENCES marketplace_listings(listing_id) ON DELETE CASCADE,
  CONSTRAINT fk_cm_lf    FOREIGN KEY (lost_found_id) REFERENCES lost_found_items(item_id) ON DELETE CASCADE,
  CONSTRAINT chk_cm_one_target CHECK (
    (post_id IS NOT NULL) + (event_id IS NOT NULL) + (help_request_id IS NOT NULL)
    + (listing_id IS NOT NULL) + (lost_found_id IS NOT NULL) = 1
  ),
  INDEX idx_cm_post (post_id),
  INDEX idx_cm_event (event_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 14. Reactions (one reaction per user per content)
-- -----------------------------------------------------
CREATE TABLE reactions (
  reaction_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  post_id         INT UNSIGNED NULL,
  event_id        INT UNSIGNED NULL,
  comment_id      INT UNSIGNED NULL,
  reaction_type   ENUM('like','love','helpful','sad','angry') NOT NULL DEFAULT 'like',
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rx_user    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_rx_post    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
  CONSTRAINT fk_rx_event   FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
  CONSTRAINT fk_rx_comment FOREIGN KEY (comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE,
  CONSTRAINT chk_rx_one_target CHECK (
    (post_id IS NOT NULL) + (event_id IS NOT NULL) + (comment_id IS NOT NULL) = 1
  ),
  UNIQUE KEY uq_rx_post    (user_id, post_id),
  UNIQUE KEY uq_rx_event   (user_id, event_id),
  UNIQUE KEY uq_rx_comment (user_id, comment_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 15. Notifications
-- -----------------------------------------------------
CREATE TABLE notifications (
  notification_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  type            ENUM('post','event','help_request','service','marketplace',
                       'lost_found','emergency','comment','reaction','report','system') NOT NULL,
  message         VARCHAR(255) NOT NULL,
  reference_id    INT UNSIGNED NULL,
  is_read         BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_nt_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_nt_user_unread (user_id, is_read, created_at)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- 16. Reports & Moderation
-- -----------------------------------------------------
CREATE TABLE reports (
  report_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reporter_id   INT UNSIGNED NOT NULL,
  target_type   ENUM('post','comment','event','help_request','service',
                     'listing','lost_found','user') NOT NULL,
  target_id     INT UNSIGNED NOT NULL,
  reason        ENUM('spam','abuse','inappropriate','scam','false_info','harassment','other') NOT NULL,
  details       TEXT,
  status        ENUM('pending','under_review','resolved','dismissed') NOT NULL DEFAULT 'pending',
  reviewed_by   INT UNSIGNED NULL,
  action_taken  ENUM('none','content_removed','warning_sent','user_suspended','user_banned') NOT NULL DEFAULT 'none',
  admin_note    TEXT,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  reviewed_at   DATETIME NULL,
  CONSTRAINT fk_rp_reporter FOREIGN KEY (reporter_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_rp_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(user_id) ON DELETE SET NULL,
  INDEX idx_rp_status (status, created_at),
  INDEX idx_rp_target (target_type, target_id)
) ENGINE=InnoDB;

-- =====================================================
--  SEED DATA
-- =====================================================
INSERT INTO roles (role_name) VALUES ('Resident'), ('Service Provider'), ('Admin');

INSERT INTO post_categories (name) VALUES
  ('General'), ('Safety'), ('Environment'), ('Education'), ('Health'), ('Announcement');

INSERT INTO service_categories (name) VALUES
  ('Plumbing'), ('Electrician'), ('Tutoring'), ('Cleaning'),
  ('Delivery'), ('Medical'), ('Repair & Maintenance');

INSERT INTO neighborhoods (name, area, city) VALUES
  ('Green Valley', 'Savar', 'Dhaka'),
  ('Lake View',    'Uttara', 'Dhaka');

-- NOTE: password_hash below is a placeholder.
-- In Node.js, generate real hashes with bcrypt and store those instead.
INSERT INTO users (role_id, neighborhood_id, full_name, username, email, phone, password_hash) VALUES
  (3, 1, 'Site Admin',     'admin',    'admin@neighborhood.local',    '01700000001', '$2b$10$REPLACE_WITH_REAL_BCRYPT_HASH'),
  (1, 1, 'Rahim Uddin',    'rahim',    'rahim@example.com',           '01700000002', '$2b$10$REPLACE_WITH_REAL_BCRYPT_HASH'),
  (1, 1, 'Karima Begum',   'karima',   'karima@example.com',          '01700000003', '$2b$10$REPLACE_WITH_REAL_BCRYPT_HASH'),
  (2, 1, 'Sohel Electric', 'sohel_el', 'sohel@example.com',           '01700000004', '$2b$10$REPLACE_WITH_REAL_BCRYPT_HASH');

INSERT INTO user_profiles (user_id, address, bio) VALUES
  (2, 'House 12, Road 3, Green Valley', 'Long-time resident'),
  (3, 'House 45, Road 5, Green Valley', 'Teacher and community volunteer');

INSERT INTO posts (user_id, neighborhood_id, category_id, post_type, title, description) VALUES
  (2, 1, 1, 'post', 'Welcome to Green Valley', 'Hello neighbors! Use this feed to share local updates.'),
  (1, 1, 6, 'announcement', 'Water supply maintenance', 'Water supply will be off on Friday 10am-2pm.');

INSERT INTO events (created_by, neighborhood_id, title, description, event_date, event_time, location) VALUES
  (3, 1, 'Community Clean-up Day', 'Join us to clean our streets.', '2026-11-07', '08:00:00', 'Green Valley Park');

INSERT INTO event_participants (event_id, user_id) VALUES (1, 2);

INSERT INTO help_requests (user_id, neighborhood_id, help_type, title, details) VALUES
  (2, 1, 'grocery', 'Need grocery help', 'Unable to go out this week, need basic groceries.');

INSERT INTO help_responses (help_request_id, responder_id, message) VALUES
  (1, 3, 'I can bring them tomorrow morning.');

INSERT INTO services (provider_id, neighborhood_id, service_category_id, service_name, description, contact_phone, price_info) VALUES
  (4, 1, 2, 'Home Electrical Repair', 'Wiring, fan and light repair at home.', '01700000004', 'From 300 BDT');

INSERT INTO marketplace_listings (user_id, neighborhood_id, listing_type, title, description, item_condition, price) VALUES
  (2, 1, 'sell', 'Study table', 'Wooden study table in good condition.', 'used', 2500.00);

INSERT INTO lost_found_items (user_id, neighborhood_id, report_type, item_name, description, location, date_occurred) VALUES
  (3, 1, 'lost', 'Black wallet', 'Lost near the park gate.', 'Green Valley Park', '2026-10-10');

INSERT INTO emergency_alerts (created_by, neighborhood_id, title, message, severity) VALUES
  (1, 1, 'Gas leakage warning', 'Gas leakage reported on Road 3. Avoid open flames.', 'high');

INSERT INTO comments (user_id, post_id, content) VALUES (3, 1, 'Great initiative!');
INSERT INTO reactions (user_id, post_id, reaction_type) VALUES (3, 1, 'like');

INSERT INTO notifications (user_id, type, message, reference_id) VALUES
  (2, 'comment', 'Karima commented on your post', 1);

INSERT INTO reports (reporter_id, target_type, target_id, reason, details) VALUES
  (3, 'post', 1, 'spam', 'Sample report for testing moderation flow.');
