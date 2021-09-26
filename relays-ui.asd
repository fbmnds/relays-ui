
(asdf:defsystem #:relays-ui
  :description "Describe ps-react-example here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on
  (#:asdf
   #:quicklisp
   #:parenscript
   #:paren6
   #:html-entities
   #:spinneret
   #:spinneret/ps
   #:rx
   #:clack
   #:woo
   #:optima
   #:alexandria
   #:uiop)
  :components
  ((:file "packages")
   ;;(:file "psx")
   (:module "src"
    :components
    ((:file "env")
     (:file "alerts")
     (:file "relays")
     (:file "lines")
     (:file "tabs")
     (:file "spa")))
#|
   (:module "t"
    :components
    ((:file "load")))
|#
   ))


