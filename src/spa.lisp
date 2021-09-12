
(in-package #:relays-ui)


(defparameter *app-js*
  (ps:ps* `(progn
             (alert-fn)
             (toggle-switch-fn)
             (relay-switch-fn 1)
             (relay-switch-fn 2)
             (relay-switch-fn 3)
             (relay-switch-fn 4)
             (relay-url-fn)
             (relays-fn)
             (render-relays))))

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
      (:div :id "relays" :class "relays")
      (:script :type "application/javascript" :src "/js/App.js")))))

(defun route (env-path path rc hdr body &optional ends-with)
  (when (if ends-with
            (a:ends-with-subseq path env-path)
            (a:starts-with-subseq path env-path))
    (if (pathnamep body)
        `(,rc ,hdr ,body)
        `(,rc ,hdr (,body)))))

(defun handler (env)
  (let ((js-hdr '(:content-type "application/javascript"))
        (path (getf env :path-info)))
    (handler-case
        (or
         (route path "/index.html" 200 nil *index*)
         (route path "/js/react.js" 200 js-hdr *react*)
         (route path "/js/react-dom.js" 200 js-hdr *react-dom*)
         (route path "/js/react-bootstrap.js" 200 js-hdr *react-bootstrap*)
         (route path "/js/App.js" 200 js-hdr *app-js*)
         (route path "/css/toggle-switch.css" 200 nil *toggle-switch-css* t)
         (route path "/css/bootstrap.css" 200 nil *bootstrap-css* t)
         (route path "/js/bootstrap-bundle.js" 200 js-hdr *bootstrap-bundle-js*)
         (route path "/assets/favicon.ico"
                200 '(:content-type "image/x-icon") *favicon* t)
         `(404 nil (,(format nil "Path not found~%"))))
      (t (e) (if *debug*
                 `(500 nil (,(format nil "Internal Server Error~%~A~%" e)))
                 `(500 nil (,(format nil "Internal Server Error"))))))))

