
(in-package :relays-ui)


(rx:defm inner-span ()
  `(let ((class-name-inner-switch
           (if disabled@
               "toggle-switch-inner toggle-switch-disabled"
               "toggle-switch-inner")))
     (rx:react-element :span
                       (rx:{} class-name class-name-inner-switch
                              "data-yes" data-yes@
                              "data-no" data-no@
                              tab-index -1))))

(rx:defm switch-span ()
  `(let ((class-name-switch-span
           (if disabled@
               "toggle-switch-switch toggle-switch-disabled"
               "toggle-switch-switch")))
     (rx:react-element :span
                       (rx:{} class-name class-name-switch-span
                              tab-index -1))))

(rx:defm toggle-label ()
  `(if id@
       (rx:react-element :label
                         (rx:{} class-name "toggle-switch-label"
                                html-for id@
                                tab-index (if disabled@ -1 1)
                                on-key-down handle-key-press)
                         (inner-span)
                         (switch-span))
       (rx:react-element :div nil)))

(rx:defm toggle-input ()
  `(rx:react-element :input
                     (rx:{} type "checkbox"
                            class-name "toggle-switch-checkbox"
                            name name@
                            id id@
                            checked checked@
                            disabled disabled@
                            on-change on-change@)))

(rx:defm toggle-switch-fn ()
  `(defun -toggle-switch (props)
     (rx:use-state "checked" 'false)
     (let* ((name@ (rx:@ props name))
            (id@ (rx:@ props id))
            (checked@ (rx:@ props checked))
            (disabled@ (rx:@ props disabled))
            (small@ (rx:@ props small))
            (option-labels@ (rx:@ props option-labels))
            (data-yes@ (or (rx:@ option-labels@ 0) "yes"))
            (data-no@ (or (rx:@ option-labels@ 0) "no"))
            (on-change@ (rx:@ props on-change)))
       (rx:react-element :div
                         (rx:{} class-name (if small@
                                               "toggle-switch small-switch"
                                               "toggle-switch"))
                         (toggle-input)
                         (toggle-label)))))

(rx:defm render-toggle-switch (tag props)
  `(rx:react-dom-render (rx:react-element -toggle-switch ,props)
                        (rx:doc-element ,tag)))

(rx:defm toggle-relay-fn (relay-nr url)
  `(rx:js (format nil "async function toggleRelay~a () { 
    try {
        const response = await fetch('~a/r~a', {
            mode: 'no-cors',
            cache: 'no-cache'
        });
        setRelay~a(!relay~a)
        return true;
    } catch (e) { return null; }
}" ,relay-nr ,url ,relay-nr ,relay-nr ,relay-nr)))

(rx:defm relay-switch-fn (state relay-nr text url)
  (let ((id (format nil "r~a" relay-nr))
        (fname (make-symbol (format nil "-relay-switch~a" relay-nr)))
        (toggle-relay (make-symbol (format nil "toggle-relay~a" relay-nr)))
        (checked (make-symbol (format nil "relay-~a" relay-nr))))
    `(defun ,fname ()
       (rx:use-state ,state 'false)
       (toggle-relay-fn ,relay-nr ,url)
       (let ((props (rx:{} id ,id
                           html-for ,id
                           text ,text
                           checked ,checked
                           on-change ,toggle-relay)))
         (rx:react-element :div nil
                           (rx:react-element -toggle-switch props)
                           (rx:react-element :label
                                             nil
                                             ,text))))))

(rx:defm render-relay-switch (relay-nr tag)
  (let ((fname (make-symbol (format nil "-relay-switch~a" relay-nr))))
    `(rx:react-dom-render (rx:react-element ,fname)
                        (rx:doc-element ,tag))))




