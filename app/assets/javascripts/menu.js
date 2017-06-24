(function() {
    "use strict";
    let activeContainer = null;

    function fire(e) {
      console.log(e);
    }

    function observe(selector, func){
      $(document).on('change', selector, function(){
        console.log(this);
      })
      console.log(func);
    }

    function activate(container) {
      if (activeContainer) {
        deactivate(activeContainer)
      }

      if (!fire(container, 'menu:activate')) return

      $(document).on('keydown.menu', onKeyDown)
      $(document).on('click.menu', onDocumentClick)
      activeContainer = container
      performTransition(container, () => {
        container.classList.add('active')

        const focusable = container.querySelector('.js-menu-content [tabindex]')
        if (focusable) focusable.focus()

        const target = container.querySelector('.js-menu-target')
        if (target) {
          target.setAttribute('aria-expanded', 'true')

          if (!target.hasAttribute('data-no-toggle'))
            target.classList.add('selected')
        }
      })
      deprecatedFire(container, 'menu:activated', {async: true})
    }

    function deactivate(container) {
      if (!container) return
      if (!fire(container, 'menu:deactivate')) return

      $(document).off('.menu')
      activeContainer = null
      performTransition(container, () => {
        container.classList.remove('active')

        const content = container.querySelector('.js-menu-content')
        if (content) {
          content.setAttribute('aria-expanded', 'false')
        }

        const target = container.querySelector('.js-menu-target')
        if (target) {
          target.setAttribute('aria-expanded', 'false')

          if (!target.hasAttribute('data-no-toggle'))
            target.classList.remove('selected')
        }
      })
      deprecatedFire(container, 'menu:deactivated', {async: true})
    }

    // Handle document click event
    //
    // Deactivates menu if click if outside the active menu container.
    //
    // event - jquery.Event
    //
    // Returns nothing.
    function onDocumentClick(event) {
      if (!activeContainer) return

      // The menu itself or interacting with a facebox.
      // We allow clicking in a facebox since the facebox
      // may be a result of interacting with the menu which
      // is the case for SSO expiry modals.
      const allowedClickTarget = $(event.target).closest(activeContainer)[0] ||
        event.target.closest("#facebox, .facebox-overlay")

      if (!allowedClickTarget) {
        event.preventDefault()
        deactivate(activeContainer)
      }
    }

    // Handle document keydown event
    //
    // Deactivates menu if ESC key is pressed.
    //
    // event - jquery.Event
    //
    // Returns nothing.
    function onKeyDown(event) {
      if (!activeContainer) return

      const activeElement = document.activeElement
      if (activeElement && hotkey(event.originalEvent) === 'esc') {
        const parents = $(activeElement).parents().get()
        if (parents.indexOf(activeContainer) >= 0) {
          activeElement.blur()
        }
        event.preventDefault()
        deactivate(activeContainer)
      }
    }

    // Handle container click event
    //
    // If the menu isn't active, clicks to the target activate the
    // menu. If the menu is already active, clicks outside of the content
    // deactivate it.
    //
    // event - jquery.Event
    //
    // Returns nothing.
    $(document).on('click', '.js-menu-container', function(event) {
      const container = this
      const target = $(event.target).closest('.js-menu-target')[0]
      if (target) {
        event.preventDefault()
        if (container === activeContainer) {
          deactivate(container)
        } else {
          activate(container)
        }
      } else if ($(event.target).closest('.js-menu-content')[0]) {
        // Do nothing when content is clicked.
      } else if (container === activeContainer) {
        event.preventDefault()
        deactivate(container)
      }
    });

    // Handle close click event
    //
    // Deactivate menu if ".close" element is clicked.
    //
    // event - jquery.Event
    //
    // Returns nothing.
    $(document).on('click', '.js-menu-container .js-menu-close', function(event) {
      deactivate(this.closest('.js-menu-container'))
      event.preventDefault()
    });

    observe('.js-menu-container.active', {
      add: function() {
        const body = document.body
        invariant(body)
        body.classList.add('menu-active')
      },
      remove: function() {
        const body = document.body
        invariant(body)
        body.classList.remove('menu-active')
      }
    });
}).call(this);
