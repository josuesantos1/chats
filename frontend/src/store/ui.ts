import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUiStore = defineStore('ui', () => {
  const contactsModalOpen = ref(false)
  const newGroupModalOpen = ref(false)

  function openContactsModal() {
    contactsModalOpen.value = true
  }

  function closeContactsModal() {
    contactsModalOpen.value = false
  }

  function openNewGroupModal() {
    newGroupModalOpen.value = true
  }

  function closeNewGroupModal() {
    newGroupModalOpen.value = false
  }

  return {
    contactsModalOpen,
    newGroupModalOpen,
    openContactsModal,
    closeContactsModal,
    openNewGroupModal,
    closeNewGroupModal,
  }
})
