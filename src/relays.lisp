
(in-package :relays-ui)


(rx:defm status-relay-fn ()
  `(rx:js (format nil "
    function statusRelay (url) { 
    try {
        setDisabled1(true);
        setDisabled2(true);
        setDisabled3(true);
        setDisabled4(true);
        fetch(url + '/?')
        .then(r => r.json())
        .then(state => {
              console.log(state);
              setRelay1(state.r1===1?true:false);
              setRelay2(state.r2===1?true:false);
              setRelay3(state.r3===1?true:false);
              setRelay4(state.r4===1?true:false);
              setDisabled1(false);
              setDisabled2(false);
              setDisabled3(false);
              setDisabled4(false);
        });
    } catch (e) { 
        setDisabled1(false);
        setDisabled2(false);
        setDisabled3(false);
        setDisabled4(false);
    }
    return null;
}")))

(rx:defm toggle-relay-fn ()
  `(rx:js (format nil "function toggleRelay (relay_nr,url) { 
    relay_nr===1?setDisabled1(true):
    relay_nr===2?setDisabled2(true):
    relay_nr===3?setDisabled3(true):
    relay_nr===4?setDisabled4(true):
    console.log('error relay_nr ' + relay_nr); 
    
(function () {
    try {
        fetch(url + '/r' + relay_nr)
        .then(res => res.json())
        .then(state => {
              setRelay1(state.r1===1?true:false);
              setRelay2(state.r2===1?true:false);
              setRelay3(state.r3===1?true:false);
              setRelay4(state.r4===1?true:false);
              relay_nr===1?setDisabled1(false):
              relay_nr===2?setDisabled2(false):
              relay_nr===3?setDisabled3(false):
              relay_nr===4?setDisabled4(false):
              console.log('error relay_nr ' + relay_nr);
        });
    } catch (e) { 
        console.log('error toggleRelay' + e.toString()); 
        return null;
    }
})();
}")))

(rx:defm relay-switch-fn (fname-root relay-nr)
  (let* ((root (format nil "~a-~a" fname-root relay-nr))
         (fname (make-symbol root))
         (id (remove #\- root))
         (text (format nil "Relay ~a" relay-nr)))
    `(defun ,fname (props)
       (let ((props2 (rx:{} id ,id
                           html-for ,id
                           text ,text
                           checked (rx:@ props checked)
                           disabled (rx:@ props disabled)
                           option-labels (ps:array " " " ")
                           on-change (ps:@ props on-change))))
         (rx:react-element :div (rx:{} class-name (if (rx:@ props2 disabled)
                                                      "relay relay-disabled"
                                                      "relay"))
                           (rx:react-element -toggle-switch props2)
                           (rx:react-element :div nil ,text))))))

(rx:defm render-relay-switch (url-label relay-nr)
  (let ((fname (make-symbol (format nil "~a~a" url-label relay-nr)))
        (tag (format nil "relay~a" relay-nr)))
    `(rx:react-dom-render (rx:react-element ,fname)
                          (rx:doc-element ,tag))))

(rx:defm relay-url-fn ()
  `(defun -relay-url (props)
     (rx:react-element -Alert props)))

(rx:defm render-relay-url (tag)
  `(rx:react-dom-render (rx:react-element -relay-url)
                        (rx:doc-element ,tag)))

(rx:defm relays-fn (fname url url-label)
  (let* ((fn- (symbol-name fname))
         (fname1 (make-symbol (format nil "~a-1" fn-)))
         (fname2 (make-symbol (format nil "~a-2" fn-)))
         (fname3 (make-symbol (format nil "~a-3" fn-)))
         (fname4 (make-symbol (format nil "~a-4" fn-))))
    `(defun ,fname (props)
       (defvar url ,url)
       (rx:use-state "relay1" 'false)
       (rx:use-state "relay2" 'false)
       (rx:use-state "relay3" 'false)
       (rx:use-state "relay4" 'false)
       (rx:use-state "disabled1" 'false)
       (rx:use-state "disabled2" 'false)
       (rx:use-state "disabled3" 'false)
       (rx:use-state "disabled4" 'false)
       (toggle-relay-fn)
       (status-relay-fn)
       (rx:tlambda () (status-relay url))
       (rx:js "React.useEffect(() => { statusRelay(url); }, []);")
       (rx:react-element
        :div nil
        (rx:react-element ,fname1
                          (rx:{} id ,fname1
                                 class-name "relay"
                                 checked relay1
                                 disabled disabled1
                                 on-change (rx:tlambda ()
                                                       (toggle-relay 1 url))))
        (rx:react-element ,fname2
                          (rx:{} id ,fname2
                                 class-name "relay"
                                 checked relay2
                                 disabled disabled2
                                 on-change (rx:tlambda ()
                                                       (toggle-relay 2 url))))
        (rx:react-element ,fname3
                          (rx:{} id ,fname3
                                 class-name "relay"
                                 checked relay3
                                 disabled disabled3
                                 on-change (rx:tlambda ()
                                                       (toggle-relay 3 url))))
        (rx:react-element ,fname4
                          (rx:{} id ,fname4
                                 class-name "relay"
                                 checked relay4
                                 disabled disabled4
                                 on-change (rx:tlambda ()
                                                       (toggle-relay 4 url))))
        (rx:react-element -relay-url (rx:{} variant
                                            (if (or disabled1
                                                    disabled2
                                                    disabled3
                                                    disabled4)
                                                "info"
                                                "light")
                                            text ,url-label))))))

(rx:defm render-relays ()
  `(progn
     (rx:react-dom-render (rx:react-Element -relays-16-e5-f0 nil)
                          (rx:doc-element "ESP-16E5F0"))
     (rx:react-dom-render (rx:react-Element -relays-4-d-c-c5-f nil)
                          (rx:doc-element "ESP-4DCC5F"))))



