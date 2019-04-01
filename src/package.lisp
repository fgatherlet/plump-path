(defpackage plump-path
  (:nicknames
   :ppath
   )
  (:export

   :ppath
   :ppath-all

   :pnode-attr
   :pnode-attrs
   :pnode-parent
   :pnode-children

   :pnode-name-p
   :pnode-attr-p

   :?
   :{}
   :@
   :@~
   :>>
   )
  (:use
   :cl
   :series
   )
  (:import-from
   :let-over-lambda
   :defmacro!
   :mkstr
   :symb
   :plambda
   :with-pandoric)
  (:import-from
   :alexandria
   :when-let
   :when-let*
   :if-let
  ))


;; blah blah blah.
