
(in-package #:relays-ui)

(defparameter *alert-categories*
  (list "primary"
        "success"
        "danger"
        "warning"
        "info"
        "light"
        "dark"))

(rx:defm alert-fn ()
  `(defun -alert (props)
     (rx:react-element (ps:@ -react-bootstrap -alert)
                       props
                       (rx:@ props text))))

(rx:defm render-alert (props tag)
  `(rx:react-dom-render (rx:react-element -alert ,props)
                        (rx:doc-element ,tag)))


