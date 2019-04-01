(in-package :plump-path)

;; abstract plump node

(defun pnode-attr (x key)
  (when (plump:element-p x)
    (plump:attribute x (string-downcase (mkstr key)))))

(defun pnode-attrs (x)
  (when (plump:element-p x)
    (plump:attributes x)))

(defun pnode-nesting-p (x)
  (plump:nesting-node-p x))

(defun pnode-parent (x)
  (when (plump:child-node-p x)
    (plump:parent x)))

(defun pnode-children (x)
  (when (plump:nesting-node-p x)
    (plump:children x)))

(defun pnode-name-p (x value)
  (when (plump:element-p x)
    (equalp (plump:tag-name x) (string-downcase (mkstr value)))))

(defun pnode-attr-p (x key value)
  (when (plump:element-p x)
    (equalp (plump:attribute x (string-downcase (mkstr key)))
            value)))


;; memo: plump class

;; lv0
;; nesting
;; child
;; textual

;; lv1
;; root(nesting)
;; element(nesting child)
;; text(child textual)
;; comment(child textual)
;; cdata(child textual)

;; lv2
;; full-text(element)

;;;;;; tidy up plump dom
;; nesting (root, element)
;; text

;; nesting : children, parent, tag-name, attributes
;; text    : parent, text

