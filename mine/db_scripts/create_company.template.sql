CREATE TABLE IF NOT EXISTS `company_%(symbol)s` (
  `date` date NOT NULL,
  `volume` float DEFAULT NULL,
  `high_price` float DEFAULT NULL,
  `low_price` float DEFAULT NULL,
  `open_price` float DEFAULT NULL,
  `close_price` float DEFAULT NULL,
  `close_adjusted` float DEFAULT NULL,
  `price_change` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1