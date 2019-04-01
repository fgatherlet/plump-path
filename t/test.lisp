;; (ql:quickload '(:plump-path-test :prove))
(defpackage plump-path-test
  (:use
   :cl
   :plump-path
   :series
   :prove))
(in-package :plump-path-test)

;; NOTE: To run this test file, execute `(asdf:test-system :plump-path)' in your Lisp.

;; (plump:tag-name *root*)
;; (plump:element-p *root*)


(plan nil)


(defvar *root* nil)

(let ((path (asdf:system-relative-pathname :plump-path "t/a0.html"))
      html)
  (unless (probe-file path)
    (setq html (dex:get "https://en.wikipedia.org/wiki/Common_Lisp"))
    (collect-file path (scan html) #'write-char))

  (setq html (collect 'string (scan-file path #'read-char)))
  (setq *root* (plump:parse html)))

(print *root*)
(print (pnode-children *root*))

(ok
 (ppath *root*
   *
   >
   :html
   >
   :body
   >
   *
   ))

(ok (< 0
       (length
        (ppath-all *root*
          *
          >
          :html
          >
          :body
          >
          *
          ))))

(is-error
 (eval
  `(ppath *root*
     (* *)))
 #+sbcl sb-c:compiler-error
 #-sbcl condition
 )

(format t "~&[~s]~%"
        (ppath
            *root*
          ({} 0 9 * >)
          :html
          ))

(pnode-children
 (ppath
     *root*
   ({} 0 9 * >)
   :html
   ))



(ok
 (ppcre:scan
  "hid.en"
  (pnode-attr
   (ppath *root*
     (* * >)
     (@~ :class "hid.en")
     )
   :class)))

(is
 (ppath *root*
   (* * >)
   (@~ :class "hid.en"))
 (ppath *root*
   (* * >)
   (lambda (x)
     (ppcre:scan
      "hid.en"
      (pnode-attr x :class)
      ))))


;;(ppath *root* (* * >) :a)


(finalize)
