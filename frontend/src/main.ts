import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { VueQueryPlugin } from '@tanstack/vue-query'
import { Toaster } from 'vue-sonner'
import { OhVueIcon, addIcons } from 'oh-vue-icons'
import {
  HiSearch, HiX, HiChevronUp, HiChevronDown, HiPlus,
  HiUserGroup, HiUser, HiChatAlt2, HiTrash, HiArrowLeft,
  HiSolidArrowLeft, HiSolidX, HiSolidCheck,
   
  HiAtSymbol, HiMail,
} from 'oh-vue-icons/icons/hi'
import { MdSend } from 'oh-vue-icons/icons/md'
import router from './routes'
import App from './App.vue'
import './style.css'

addIcons(
  HiSearch, HiX, HiChevronUp, HiChevronDown, HiPlus,
  HiUserGroup, HiUser, HiChatAlt2, HiTrash, HiArrowLeft,
  HiSolidArrowLeft, HiSolidX, HiSolidCheck,
  HiAtSymbol, HiMail,
  MdSend,
)

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(VueQueryPlugin)
// eslint-disable-next-line vue/multi-word-component-names
app.component('Toaster', Toaster)
 
app.component('VIcon', OhVueIcon)

app.mount('#app')
