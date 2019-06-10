# Plump-Path - query to handle plump dom.

## Synopsis

```
(pushnew #p"~/<somewhere>/plump-path/" asdf:*central-registry* :test 'equal)
(ql:quickload :plump-path)
(ql:quickload :dexador)
(use-package :plump-path)

;; attribute match
(let* ((html (dex:get "https://www.google.com"))
       (dom (plump:parse html)))
  (ppath dom :>> :input (:@ "name" "q")))
;; #<PLUMP-DOM:ELEMENT input {1002D7C823}>

;; regex
(let* ((html (dex:get "https://www.google.com"))
       (dom (plump:parse html)))
  (ppath dom :>> :input (:@~ "name" "[a-z]")))
;; #<PLUMP-DOM:ELEMENT input {1002D7C823}>

;; parent
(let* ((html (dex:get "https://www.google.com"))
       (dom (plump:parse html)))
  (ppath dom :>> :input (:@ "name" "q")
         :<
         ))

;; directory
(let* ((html (dex:get "https://www.google.com"))
       (dom (plump:parse html)))
  (ppath-all dom :>> :div :> :div :> :a))
;; xpath //div/div/a

;; lambda predicate
(let* ((html (dex:get "https://www.google.com"))
       (dom (plump:parse html)))
  (ppath-all dom :>> (lambda (node)
                       (and
                        (plump:element-p node)
                        (equal (plump:tag-name node) "input")
                        (equal (plump:attribute node "name") "q")))))


```

## Description

`plump-path` is the query library for the dom tree which is parsed with [plump](https://github.com/Shinmera/plump) (xml, html parser).

it is common lisp library. it is like xpath or css selector but quering with s expression.

you can query dom with regular expression and lambda predicate.

## See also

- [plump](https://github.com/Shinmera/plump)

## Bugs

- api is unstable.

- "query sibling" is not implemented.

## Author

* fgatherlet (fgatherlet@gmail.com)

## Copyright

Copyright (c) 2019 fgatherlet (fgatherlet@gmail.com)



## License

Licensed under the MIT License.

