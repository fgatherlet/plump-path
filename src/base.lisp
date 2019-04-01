(in-package :plump-path)

(defvar *all-p* nil)
(defvar *result* nil)
(defvar *depth* nil)

(defun pvalues (x)
  (push x *result*)
  x)

(defmacro ppath% (dom &body ms)
  (let ((matcher (compile-m (cons 'cl:do ms) #'pvalues)))
    `(funcall ,matcher ,dom)))






