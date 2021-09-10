
(in-package #:relays-ui)


(defparameter *app-js*
  (apply #'concatenate 'string
         (cons
          (ps:ps* `(toggle-switch-fn))
          (mapcar #'(lambda (i)
                     (let ((state (format nil "relay~a" i)))
                       (ps:ps*
                        `(progn
                           (relay-switch-fn ,state ,i ,state ,*relay-url*)
                           (render-relay-switch ,i ,state)
                           ))))
                 '(1 2 3 4)))))

(defmacro index ()
  (let ((divs (map 'list (lambda (v) `(:div :id ,v))
                   '("relay1"
                     "relay2"
                     "relay3"
                     "relay4"))))
    `(sp:with-html-string
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
         ,@divs
         (:script :type "application/javascript" :src "/js/App.js"))))))

(defun handler (env)
  (handler-case
      (o:match env
        ((o:guard (o:property :path-info path)
                  (a:starts-with-subseq "/index.html" path))
         `(200 nil (,(index))))
        ((o:guard (o:property :path-info path)
                  (a:starts-with-subseq "/js/react.js" path))
         `(200 (:content-type "application/javascript") (,*react*)))
        ((o:guard (o:property :path-info path)
                  (a:starts-with-subseq "/js/react-dom.js" path))
         `(200 (:content-type "application/javascript") (,*react-dom*)))
        ((o:guard (o:property :path-info path)
                  (a:starts-with-subseq "/js/react-bootstrap.js" path))
         `(200 (:content-type "application/javascript") (,*react-bootstrap*)))
        ((o:guard (o:property :path-info path)
                  (a:starts-with-subseq "/js/App.js" path))
         `(200 (:content-type "application/javascript") (,*app-js*)))
        ((o:guard (o:property :path-info path)
                  (a:starts-with-subseq "/css/base.css" path))
         `(200 nil (,*toggle-switch-css*)))
        ((o:guard (o:property :path-info path)
                  (a:starts-with-subseq "/css/toggle-switch.css" path))
         `(200 nil (,*toggle-switch-css*)))
        ((o:guard (o:property :path-info path)
                  (a:starts-with-subseq "/css/bootstrap.css" path))
         `(200 nil (,*bootstrap-css*)))
        ((o:guard (o:property :path-info path)
                  (a:starts-with-subseq "/js/bootstrap-bundle.js" path))
         `(200 (:content-type "application/javascript") (,*bootstrap-bundle-js*)))
        ((o:guard (o:property :path-info path)
                  (a:ends-with-subseq "/assets/favicon.ico" path))
         `(200 (:content-type "image/x-icon") ,*favicon*))
        ((o:property :path-info path)
         `(404 nil (,(format nil "Path ~A not found~%" path)))))
    (t (e) (if *debug*
               `(500 nil (,(format nil "Internal Server Error~%~A~%" e)))
               `(500 nil (,(format nil "Internal Server Error")))))))

