(in-package :plump-path)

(defmacro ppath (dom &body ms)
  `(let ((*result* nil))
     (ppath% ,dom ,@ms)
     (car *result*)))

(defmacro ppath-all (dom &body ms)
  `(let ((*result* nil)
         (*all-p* t))
     (ppath% ,dom ,@ms)
     (remove-duplicates *result*)))

