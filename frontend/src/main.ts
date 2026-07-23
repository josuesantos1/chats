import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { VueQueryPlugin } from '@tanstack/vue-query'
import { Toaster } from 'vue-sonner'
import router from './routes'
import App from './App.vue'
import './style.css'

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(VueQueryPlugin)
// eslint-disable-next-line vue/multi-word-component-names
app.component('Toaster', Toaster)

app.mount('#app')
