export default defineNuxtRouteMiddleware((to, from) => {
  console.log('[DEBUG ROUTER] Navigating:', {
    to: to.fullPath,
    from: from.fullPath,
    params: to.params,
    query: to.query
  })
})
