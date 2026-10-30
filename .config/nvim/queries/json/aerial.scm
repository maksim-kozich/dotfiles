; extends
; aerial's json query lists only objects; add arrays and plain values, like PyCharm

(pair
  key: (string
    (string_content) @name)
  value: (array) @symbol
  (#set! "kind" "Enum")) @start

(pair
  key: (string
    (string_content) @name)
  value: [(string) (number) (true) (false) (null)] @symbol
  (#set! "kind" "Property")) @start
