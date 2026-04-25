/**
 * OhMyPm 原型共享交互脚本
 * 用途：评审原型的通用交互壳，不承载业务逻辑
 * 原则：壳是通用的，业务逻辑由各页面 HTML 自行实现
 *
 * 提供的能力：
 * 1. 页面路由（SPA 式页面切换）
 * 2. 弹窗/抽屉（打开/关闭/遮罩层点击）
 * 3. Tab 切换
 * 4. Toast 提示（成功/错误/警告/信息）
 * 5. Loading 状态
 * 6. 下拉选择（展开/收起/选中）
 * 7. 表单必填校验（仅空值校验壳）
 * 8. 确认对话框
 */

;(function () {
  "use strict";

  // ============================================
  // 1. 页面导航（多页原型）
  // ============================================
  const Nav = {
    init() {
      // 监听所有带 data-nav-to 属性的元素（值为目标 html 文件名或相对路径）
      document.addEventListener("click", (e) => {
        const link = e.target.closest("[data-nav-to]");
        if (!link) return;
        e.preventDefault();
        const target = link.getAttribute("data-nav-to");
        if (!target) return;
        this.navigate(target);
      });

      this.highlightCurrent();
    },

    navigate(target) {
      // 支持传入文件名（如 ps-01-xxx.html）或相对路径（如 docs/prototypes/ps-01-xxx.html）
      window.location.href = target;
    },

    highlightCurrent() {
      const currentFile = (window.location.pathname || "").split("/").pop() || "";

      // 更新侧边栏高亮
      document.querySelectorAll(".sidebar-nav-item").forEach((item) => {
        const to = item.getAttribute("data-nav-to") || "";
        const toFile = to.split("/").pop();
        item.classList.toggle("active", !!currentFile && toFile === currentFile);
      });

      // 更新面包屑（如果有）
      const breadcrumbCurrent = document.querySelector(".breadcrumb-current");
      if (breadcrumbCurrent) {
        const navItem = document.querySelector(
          `.sidebar-nav-item.active[data-nav-to]`
        );
        if (navItem) {
          breadcrumbCurrent.textContent = navItem.textContent.trim();
        }
      }
    },
  };

  // ============================================
  // 2. 弹窗/抽屉
  // ============================================
  const Modal = {
    init() {
      // 打开弹窗
      document.addEventListener("click", (e) => {
        const trigger = e.target.closest("[data-modal-open]");
        if (!trigger) return;
        const modalId = trigger.getAttribute("data-modal-open");
        this.open(modalId);
      });

      // 关闭弹窗（X 按钮）
      document.addEventListener("click", (e) => {
        const closeBtn = e.target.closest("[data-modal-close]");
        if (!closeBtn) return;
        const modalId =
          closeBtn.getAttribute("data-modal-close") ||
          closeBtn.closest(".modal-mask")?.id;
        if (modalId) this.close(modalId);
      });

      // 关闭弹窗（取消按钮）
      document.addEventListener("click", (e) => {
        const cancelBtn = e.target.closest("[data-modal-cancel]");
        if (!cancelBtn) return;
        const modalId =
          cancelBtn.getAttribute("data-modal-cancel") ||
          cancelBtn.closest(".modal-mask")?.id;
        if (modalId) this.close(modalId);
      });

      // 关闭弹窗（点击遮罩层）
      document.addEventListener("click", (e) => {
        if (!e.target.classList.contains("modal-mask")) return;
        const modalId = e.target.id;
        if (modalId) this.close(modalId);
      });

      // ESC 关闭弹窗
      document.addEventListener("keydown", (e) => {
        if (e.key !== "Escape") return;
        const openModal = document.querySelector(".modal-mask.open");
        if (openModal) this.close(openModal.id);
      });
    },

    open(modalId) {
      const mask = document.getElementById(modalId);
      if (!mask) return;
      mask.classList.add("open");
      document.body.style.overflow = "hidden";
    },

    close(modalId) {
      const mask = document.getElementById(modalId);
      if (!mask) return;
      mask.classList.remove("open");
      document.body.style.overflow = "";

      // 重置弹窗内的表单（如果有）
      const form = mask.querySelector("form");
      if (form) form.reset();

      // 清除校验错误样式
      mask.querySelectorAll(".input-error").forEach((el) => {
        el.classList.remove("input-error");
      });
      mask.querySelectorAll(".input-error-text").forEach((el) => {
        el.textContent = "";
      });
    },
  };

  // ============================================
  // 3. Tab 切换
  // ============================================
  const Tabs = {
    init() {
      document.addEventListener("click", (e) => {
        const tabItem = e.target.closest("[data-tab]");
        if (!tabItem) return;

        const tabGroup = tabItem.closest(".tabs");
        const tabContent = tabGroup?.nextElementSibling;
        if (!tabContent || !tabContent.classList.contains("tab-content")) return;

        const tabId = tabItem.getAttribute("data-tab");

        // 切换 tab 头部高亮
        tabGroup.querySelectorAll(".tab-item").forEach((item) => {
          item.classList.toggle("active", item === tabItem);
        });

        // 切换 tab 内容
        tabContent.querySelectorAll(".tab-pane").forEach((pane) => {
          pane.classList.toggle("active", pane.getAttribute("data-tab-pane") === tabId);
        });
      });
    },
  };

  // ============================================
  // 4. Toast 提示
  // ============================================
  const Toast = {
    container: null,

    init() {
      // 确保容器存在
      if (!document.querySelector(".toast-container")) {
        const container = document.createElement("div");
        container.className = "toast-container";
        document.body.appendChild(container);
      }
      this.container = document.querySelector(".toast-container");
    },

    show(message, type = "info", duration = 3000) {
      const icons = {
        success: "✓",
        error: "✕",
        warning: "!",
        info: "ℹ",
      };

      const toast = document.createElement("div");
      toast.className = `toast toast-${type}`;
      toast.innerHTML = `
        <span class="toast-icon">${icons[type] || icons.info}</span>
        <span>${message}</span>
      `;

      this.container.appendChild(toast);

      // 自动消失
      setTimeout(() => {
        toast.style.opacity = "0";
        toast.style.transform = "translateY(-8px)";
        toast.style.transition = "all 0.2s ease";
        setTimeout(() => toast.remove(), 200);
      }, duration);
    },

    success(message, duration) {
      return this.show(message, "success", duration);
    },

    error(message, duration) {
      return this.show(message, "error", duration);
    },

    warning(message, duration) {
      return this.show(message, "warning", duration);
    },

    info(message, duration) {
      return this.show(message, "info", duration);
    },
  };

  // ============================================
  // 5. Loading 状态
  // ============================================
  const Loading = {
    /**
     * 在指定容器内显示 loading
     * @param {string|HTMLElement} container - 容器选择器或元素
     * @param {string} text - 加载提示文字
     */
    show(container, text = "加载中...") {
      const el =
        typeof container === "string"
          ? document.querySelector(container)
          : container;
      if (!el) return;

      // 保存原始内容
      if (!el.dataset.loadingOriginal) {
        el.dataset.loadingOriginal = el.innerHTML;
      }

      el.innerHTML = `
        <div class="loading-block">
          <div class="loading-spinner"></div>
          <span>${text}</span>
        </div>
      `;
    },

    /**
     * 恢复容器原始内容
     * @param {string|HTMLElement} container
     */
    hide(container) {
      const el =
        typeof container === "string"
          ? document.querySelector(container)
          : container;
      if (!el || !el.dataset.loadingOriginal) return;

      el.innerHTML = el.dataset.loadingOriginal;
      delete el.dataset.loadingOriginal;
    },
  };

  // ============================================
  // 6. 下拉选择
  // ============================================
  const Select = {
    init() {
      document.addEventListener("click", (e) => {
        // 点击 select 触发器
        const trigger = e.target.closest(".select-wrapper > .select");
        if (trigger) {
          const wrapper = trigger.closest(".select-wrapper");
          const dropdown = wrapper.querySelector(".select-dropdown");
          const isOpen = dropdown?.classList.contains("open");

          // 先关闭所有其他下拉
          this.closeAll();

          if (!isOpen && dropdown) {
            dropdown.classList.add("open");
          }
          return;
        }

        // 点击选项
        const option = e.target.closest(".select-option");
        if (option) {
          const wrapper = option.closest(".select-wrapper");
          const select = wrapper.querySelector(".select");
          const dropdown = wrapper.querySelector(".select-dropdown");

          // 更新选中状态
          dropdown.querySelectorAll(".select-option").forEach((opt) => {
            opt.classList.remove("selected");
          });
          option.classList.add("selected");

          // 更新 select 显示值
          select.value = option.getAttribute("data-value") || option.textContent;

          // 触发自定义事件
          select.dispatchEvent(
            new CustomEvent("change", {
              bubbles: true,
              detail: {
                value: select.value,
                text: option.textContent.trim(),
              },
            })
          );

          dropdown.classList.remove("open");
          return;
        }

        // 点击其他区域关闭所有下拉
        if (!e.target.closest(".select-wrapper")) {
          this.closeAll();
        }
      });
    },

    closeAll() {
      document.querySelectorAll(".select-dropdown.open").forEach((dd) => {
        dd.classList.remove("open");
      });
    },
  };

  // ============================================
  // 7. 表单必填校验（仅空值校验壳）
  // ============================================
  const Form = {
    /**
     * 校验表单中的必填项（仅检查空值）
     * @param {string|HTMLElement} form - 表单选择器或元素
     * @returns {boolean} 是否通过校验
     */
    validateRequired(form) {
      const el =
        typeof form === "string" ? document.querySelector(form) : form;
      if (!el) return true;

      let isValid = true;
      const requiredInputs = el.querySelectorAll("[required]");

      requiredInputs.forEach((input) => {
        const value = input.value.trim();
        if (!value) {
          isValid = false;
          input.classList.add("input-error");

          // 查找或创建错误提示
          let errorText = input.parentElement.querySelector(".input-error-text");
          if (!errorText) {
            errorText = document.createElement("span");
            errorText.className = "input-error-text";
            input.parentElement.appendChild(errorText);
          }
          const label =
            input.closest(".input-group, .form-item")?.querySelector(
              ".input-label"
            )?.textContent?.replace("*", "") || "该字段";
          errorText.textContent = `请填写${label}`;
        } else {
          input.classList.remove("input-error");
          const errorText = input.parentElement.querySelector(".input-error-text");
          if (errorText) errorText.textContent = "";
        }
      });

      return isValid;
    },

    /**
     * 清除表单校验状态
     * @param {string|HTMLElement} form
     */
    clearValidation(form) {
      const el =
        typeof form === "string" ? document.querySelector(form) : form;
      if (!el) return;

      el.querySelectorAll(".input-error").forEach((input) => {
        input.classList.remove("input-error");
      });
      el.querySelectorAll(".input-error-text").forEach((text) => {
        text.textContent = "";
      });
    },
  };

  // ============================================
  // 8. 确认对话框
  // ============================================
  const Confirm = {
    /**
     * 显示确认对话框
     * @param {object} options
     * @param {string} options.title - 标题
     * @param {string} options.content - 内容
     * @param {string} options.confirmText - 确认按钮文字
     * @param {string} options.cancelText - 取消按钮文字
     * @param {string} options.type - 类型：default / danger
     * @returns {Promise<boolean>}
     */
    show({
      title = "确认",
      content = "",
      confirmText = "确定",
      cancelText = "取消",
      type = "default",
    } = {}) {
      return new Promise((resolve) => {
        const modalId = "confirm-modal-" + Date.now();
        const confirmBtnClass =
          type === "danger" ? "btn btn-danger" : "btn btn-primary";

        const modal = document.createElement("div");
        modal.id = modalId;
        modal.className = "modal-mask";
        modal.innerHTML = `
          <div class="modal" style="width: 400px;">
            <div class="modal-header">
              <span class="modal-title">${title}</span>
              <button class="modal-close" data-modal-close="${modalId}">✕</button>
            </div>
            <div class="modal-body">
              <p style="color: var(--color-text-primary); font-size: var(--font-size);">${content}</p>
            </div>
            <div class="modal-footer">
              <button class="btn" data-modal-cancel="${modalId}">${cancelText}</button>
              <button class="${confirmBtnClass}" id="${modalId}-confirm">${confirmText}</button>
            </div>
          </div>
        `;

        document.body.appendChild(modal);
        modal.classList.add("open");
        document.body.style.overflow = "hidden";

        const cleanup = (result) => {
          modal.remove();
          document.body.style.overflow = "";
          resolve(result);
        };

        // 确认按钮
        document
          .getElementById(`${modalId}-confirm`)
          .addEventListener("click", () => cleanup(true));

        // 取消 / 关闭
        modal.querySelector(`[data-modal-cancel="${modalId}"]`).addEventListener(
          "click",
          () => cleanup(false)
        );
        modal.querySelector(`[data-modal-close="${modalId}"]`).addEventListener(
          "click",
          () => cleanup(false)
        );

        // 点击遮罩层关闭 = 取消
        modal.addEventListener("click", (e) => {
          if (e.target === modal) cleanup(false);
        });

        // ESC 关闭 = 取消
        const escHandler = (e) => {
          if (e.key === "Escape") {
            cleanup(false);
            document.removeEventListener("keydown", escHandler);
          }
        };
        document.addEventListener("keydown", escHandler);
      });
    },
  };

  // ============================================
  // 初始化
  // ============================================
  document.addEventListener("DOMContentLoaded", () => {
    Nav.init();
    Modal.init();
    Tabs.init();
    Toast.init();
    Select.init();

    const noteCards = Array.from(document.querySelectorAll(".note-card"));

    function closeAllNotes() {
      noteCards.forEach((card) => card.classList.remove("open"));
    }

    document.addEventListener("click", (event) => {
      const trigger = event.target.closest("[data-note-target]");
      if (trigger) {
        event.stopPropagation();
        const targetId = trigger.getAttribute("data-note-target");
        const card = document.getElementById(targetId);
        if (!card) return;

        const wasOpen = card.classList.contains("open");
        closeAllNotes();
        if (wasOpen) return;

        const rect = trigger.getBoundingClientRect();
        card.classList.add("open");
        const cardWidth = card.offsetWidth || 320;
        const cardHeight = card.offsetHeight || 220;
        let left = rect.right + window.scrollX + 12;
        let top = rect.top + window.scrollY + 12;
        const maxLeft = window.scrollX + window.innerWidth - cardWidth - 12;
        const maxTop = window.scrollY + window.innerHeight - cardHeight - 12;
        if (left > maxLeft) left = rect.left + window.scrollX - cardWidth - 12;
        if (left < window.scrollX + 12) left = window.scrollX + 12;
        if (top > maxTop) top = maxTop;
        if (top < window.scrollY + 12) top = window.scrollY + 12;
        card.style.left = left + "px";
        card.style.top = top + "px";
        return;
      }

      if (event.target.closest(".note-card")) return;
      closeAllNotes();
    });

    document.querySelectorAll("[data-note-close]").forEach((button) => {
      button.addEventListener("click", (event) => {
        event.stopPropagation();
        button.closest(".note-card").classList.remove("open");
      });
    });

    let dragState = null;
    document.querySelectorAll(".note-header").forEach((header) => {
      header.addEventListener("mousedown", (event) => {
        const card = header.closest(".note-card");
        dragState = {
          card,
          offsetX: event.clientX - card.getBoundingClientRect().left,
          offsetY: event.clientY - card.getBoundingClientRect().top,
        };
      });
    });

    document.addEventListener("mousemove", (event) => {
      if (!dragState) return;
      const left = Math.max(12, Math.min(window.innerWidth - dragState.card.offsetWidth - 12, event.clientX - dragState.offsetX));
      const top = Math.max(12, Math.min(window.innerHeight - dragState.card.offsetHeight - 12, event.clientY - dragState.offsetY));
      dragState.card.style.left = left + "px";
      dragState.card.style.top = top + "px";
    });

    document.addEventListener("mouseup", () => {
      dragState = null;
    });

    const outlinePanel = document.getElementById("outlinePanel");
    const outlineToggle = document.getElementById("outlineToggle");
    if (outlinePanel && outlineToggle) {
      outlinePanel.classList.add("collapsed");
      outlineToggle.addEventListener("click", () => {
        outlinePanel.classList.toggle("collapsed");
      });
    }
  });

  // 暴露到全局，供各页面 HTML 使用
  window.OhMyPmProto = {
    Nav,
    Modal,
    Tabs,
    Toast,
    Loading,
    Select,
    Form,
    Confirm,
  };
})();
