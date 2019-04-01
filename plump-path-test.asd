#|
  This file is a part of plump-path project.
  Copyright (c) 2019 fgatherlet (fgatherlet@gmail.com)
|#

(defsystem "plump-path-test"
  :defsystem-depends-on ("prove-asdf")
  :author "fgatherlet"
  :license "MIT"
  :depends-on ("plump-path"
               "prove"
               "dexador"
               )
  :components ((:module "t"
                :components
                ((:test-file "test"))))
  :description "Test system for plump-path"

  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
