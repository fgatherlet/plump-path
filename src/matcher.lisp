(in-package :plump-path)

;; m for matcher.

(defgeneric compile-m (m cont))

(defmethod compile-m ((m list) cont)
  (compile-m-list (car m) (cdr m) cont))

(defmethod compile-m ((m symbol) cont)
  (cond
    ((null m)
     cont)
    ((member m '(* :*)) ;;(eql m '*)
     (compile-m-* cont))
    ((member m '(> :>)) ;;(eql m '>)
     (compile-m-> cont))
    ((member m '(< :<)) ;;(eql m '<)
     (compile-m-< cont))

    ((member m '(>> :>>)) ;; (eql m '>>)
     (compile-m-list '{} '(1 nil * >) cont))

    ((keywordp m)
     (compile-m-name m cont))

    (t (error "unknown m:~s" m))))

(defun compile-m-name (m cont)
  (check-type m (or string symbol))
  (lambda (x)
    (when (pnode-name-p x m)
      (funcall cont x))))

(defun compile-m-> (cont)
  "traverse children"
  (lambda (x)
    (if *all-p*
        (iterate ((xc (scan (pnode-children x))))
          (funcall cont xc))
      (collect-first
       (choose-if
        #'identity
        (mapping ((xc (scan (pnode-children x))))
          (funcall cont xc)))))))

(defun compile-m-< (cont)
  "traverse parent"
  (lambda (x)
    (when-let ((xp (pnode-parent x)))
      (funcall cont xp))))

(defun compile-m-* (cont)
  (lambda (x)
    (funcall cont x)))

;;; ------------------------------

(defgeneric compile-m-list (tag body cont))

(defmethod compile-m-list ((tag (eql 'do)) body cont)
  (labels ((make (rbody cont)
             (unless rbody (return-from make cont))
             (make (cdr rbody) (compile-m (car rbody) cont))))
    (make (reverse body) cont)))

(defmethod compile-m-list ((tag (eql 'or)) body cont)
  (let ((alts (mapcar (lambda (alt) (compile-m alt cont))
                      body)))
    (lambda (x)
      (if *all-p*
          (iterate ((alt (scan alts)))
            (funcall alt x))
        (collect-first
         (coose-if
          #'identity
          (mapping ((alt (scan alts)))
            (funcall alt x))))))))

;;(defmethod compile-m-list ((tag (eql '@)) body cont)
(defmethod compile-m-list ((tag (eql '@)) body cont)
  (destructuring-bind (key val) body
    (lambda (x)
      (when (equalp (pnode-attr x key) (mkstr val))
        (funcall cont x)))))

(defmethod compile-m-list ((tag (eql '@~)) body cont)
  (destructuring-bind (key val) body
    (let ((scanner (ppcre:create-scanner (mkstr val))))
      (lambda (x)
        (when (ppcre:scan scanner (pnode-attr x key))
          (funcall cont x))))))

(defmethod compile-m-list ((tag (eql 'lambda)) body cont)
  (let ((pred (eval (cons 'lambda body))))
    (lambda (x)
      (when (funcall pred x)
        (funcall cont x)))))

(defmethod compile-m-list ((tag (eql '{})) body cont)
  (destructuring-bind (start end &rest body) body
    (unless end (setq end (+ 65536 2))) ;; infinite
    ;; naive check if body have `:>` matcher.
    (check-type start integer)
    (check-type end (or integer null))
    (unless (find-if (lambda (x) (member x '(> :>))) body)
      (error "body of \":{}\" must has at least 1 \":>\" to avoid infinite loop."))
    (let (repetition
          (body (if (< 1 (length body)) (cons 'do body) body)))
      (flet ((walk (x)
               (let ((*depth* (1+ *depth*)))
                 #+nil(format
                       t
                       "depth[~s] body[~s] x[~s] start[~s] end[~s]~%"
                       *depth* body x start end)
                 (cond
                   ((<= 65536 *depth*)
                    ;; avoid infinite loop
                    (error "\":{}\" Call stack is too deep. Body must have at least 1 \":>\". *depth*: ~s" *depth*))
                   ((< *depth* start) (funcall repetition x))
                   ((< end *depth*)) ;; fail
                   (t
                    (if *all-p*
                        (progn
                          (funcall cont x)
                          (funcall repetition x))
                        (or (funcall cont x)
                            (funcall repetition x))))))))
        (setq repetition (compile-m body #'walk))
        (lambda (x)
          (let ((*depth* -1))
            (walk x)))))))

(defmethod compile-m-list ((tag (eql '*)) body cont)
  (compile-m-list '{} (list* 0 nil body) cont))

(defmethod compile-m-list ((tag (eql '+)) body cont)
  (compile-m-list '{} (list* 1 nil body) cont))

(defmethod compile-m-list ((tag (eql '?)) body cont)
  (compile-m-list '{} (list* 0 1 body) cont))


;; ugly. is there any better way?
#.`(progn
     ,@(loop for sym in (list :> :lambda :+ :* :? :>> :{} :@ :@~)
             collect 
             `(defmethod compile-m-list ((tag (eql ,sym)) body cont)
                (compile-m-list ',(intern (symbol-name sym)) body cont))))

#+nil(PROGN
 (DEFMETHOD COMPILE-M-LIST ((TAG (EQL :>)) BODY CONT)
   (COMPILE-M-LIST '> BODY CONT))
 (DEFMETHOD COMPILE-M-LIST ((TAG (EQL :LAMBDA)) BODY CONT)
   (COMPILE-M-LIST 'LAMBDA BODY CONT))
 (DEFMETHOD COMPILE-M-LIST ((TAG (EQL :+)) BODY CONT)
   (COMPILE-M-LIST '+ BODY CONT))
 (DEFMETHOD COMPILE-M-LIST ((TAG (EQL :*)) BODY CONT)
   (COMPILE-M-LIST '* BODY CONT))
 (DEFMETHOD COMPILE-M-LIST ((TAG (EQL :?)) BODY CONT)
   (COMPILE-M-LIST '? BODY CONT))
 (DEFMETHOD COMPILE-M-LIST ((TAG (EQL :>>)) BODY CONT)
   (COMPILE-M-LIST '>> BODY CONT))
 (DEFMETHOD COMPILE-M-LIST ((TAG (EQL :{})) BODY CONT)
   (COMPILE-M-LIST '{} BODY CONT))
 (DEFMETHOD COMPILE-M-LIST ((TAG (EQL :@)) BODY CONT)
   (COMPILE-M-LIST '@ BODY CONT))
 (DEFMETHOD COMPILE-M-LIST ((TAG (EQL :@~)) BODY CONT)
   (COMPILE-M-LIST '@~ BODY CONT)))

;;(defmethod compile-m-list ((tag (eql :@)) body cont)
;;  (compile-m-list '@ body cont))
;;(defmethod compile-m-list ((tag (eql :@~)) body cont)
;;  (compile-m-list '@~ body cont))
;;(defmethod compile-m-list ((tag (eql :?)) body cont)
;;  (compile-m-list '? body cont))
;;(defmethod compile-m-list ((tag (eql :>>)) body cont)
;;  (compile-m-list '>> body cont))
;;(defmethod compile-m-list ((tag (eql :{})) body cont)
;;  (compile-m-list '{} body cont))
;;;; > lambda + *
;;;;(ppath: ? >> {}
