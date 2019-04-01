#|
  This file is a part of plump-path project.
  Copyright (c) 2019 fgatherlet (fgatherlet@gmail.com)
|#

#|
  query to handle plump dom.

  Author: fgatherlet (fgatherlet@gmail.com)
|#

(defsystem "plump-path"
  :version "0.1.0"
  :author "fgatherlet"
  :license "MIT"
  :depends-on ("series"
               "let-over-lambda"
               "alexandria"
               "plump"
               )
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "pnode" :depends-on ("package"))
                 (:file "base" :depends-on ("pnode"))
                 (:file "matcher" :depends-on ("base"))
                 (:file "api" :depends-on ("matcher"))
                 )))
  :description "query to handle plump dom."
  :long-description
  #.(read-file-string
     (subpathname *load-pathname* "README.markdown"))
  :in-order-to ((test-op (test-op "plump-path-test"))))
