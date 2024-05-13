import './bootstrap';
import '../css/app.css'

import { createApp } from 'vue';

import App from './components/app.vue'

const app = createApp(App)

app.mount('#app')