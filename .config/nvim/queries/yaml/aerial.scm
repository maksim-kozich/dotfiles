; extends
; aerial's yaml query lists only mappings / lists; add plain values (`name: nprs`), like PyCharm

(block_mapping_pair
  key: (flow_node) @name
  value: (flow_node) @symbol
  (#set! "kind" "Property")) @start
