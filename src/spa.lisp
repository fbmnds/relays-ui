
(in-package #:relays-ui)


(defparameter *app-js*
  (ps:ps* `(progn
             (alert-fn)
             (rx:toggle-switch-fn)
             (relay-switch-fn "-relays-16-e5-f0" 1)
             (relay-switch-fn "-relays-16-e5-f0" 2)
             (relay-switch-fn "-relays-16-e5-f0" 3)
             (relay-switch-fn "-relays-16-e5-f0" 4)
             (relay-switch-fn "-relays-4-d-c-c5-f" 1)
             (relay-switch-fn "-relays-4-d-c-c5-f" 2)
             (relay-switch-fn "-relays-4-d-c-c5-f" 3)
             (relay-switch-fn "-relays-4-d-c-c5-f" 4)
             (relay-url-fn)
             (relays-fn -relays-16-e5-f0
                        "http://192.168.178.37"
                        "ESP-16E5F0")
             (relays-fn -relays-4-d-c-c5-f
                        "http://192.168.178.63" "ESP-4DCC5F")
             (tabs "-relays-16-e5-f0" "relays-tab" "mb-3" "relays"))))

(defparameter *index*
  (sp:with-html-string
    (:doctype)
    (:html
     (:head
      (:title "Hello React")
      (:link :rel "stylesheet" :href "/css/bootstrap.css")
      (:link :rel "stylesheet" :href "/css/toggle-switch.css")
      (:link :rel "icon" :href "/assets/favicon.ico")
      (:script :type "application/javascript" :src "/js/bootstrap-bundle.js")
      (:script :type "application/javascript" :src "/js/react.js")
      (:script :type "application/javascript" :src "/js/react-dom.js")
      (:script :type "application/javascript" :src "/js/react-bootstrap.js"))
     (:body
      (:div :id "relays")
      (:script :type "application/javascript" :src "/js/App.js")))))

(defun handler (env)
  (let ((js-hdr '(:content-type "application/javascript"))
        (path (getf env :path-info)))
    (handler-case
        (or
         (rx:route path "/index.html" 200 nil *index*)
         (rx:route path "/js/react.js" 200 js-hdr *react*)
         (rx:route path "/js/react-dom.js" 200 js-hdr *react-dom*)
         (rx:route path "/js/react-bootstrap.js" 200 js-hdr *react-bootstrap*)
         (rx:route path "/js/App.js" 200 js-hdr *app-js*)
         (rx:route path "/css/toggle-switch.css" 200 nil *toggle-switch-css* t)
         (rx:route path "/css/bootstrap.css" 200 nil *bootstrap-css* t)
         (rx:route path "/js/bootstrap-bundle.js" 200 js-hdr *bootstrap-bundle-js*)
         (rx:route path "/assets/favicon.ico"
                200 '(:content-type "image/x-icon") *favicon* t)
         `(404 nil (,(format nil "Path not found~%"))))
      (t (e) (if *debug*
                 `(500 nil (,(format nil "Internal Server Error~%~A~%" e)))
                 `(500 nil (,(format nil "Internal Server Error"))))))))

