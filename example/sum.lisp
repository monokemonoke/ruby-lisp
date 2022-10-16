(setq i 0)
(setq sum 0)
(while (<= i 10) (do (+= sum i) (+= i 1)))
(print sum)