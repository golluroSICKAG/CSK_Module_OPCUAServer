document.addEventListener('sopasjs-ready', () => {
  const page_1 = document.querySelector('div.sopasjs-ui-navbar-wrapper > div > ul > li:nth-child(3) > a > i');
  page_1.classList.remove('fa-file');
  page_1.classList.add('fa-lightbulb-o');

  setTimeout(() => {
    document.title = 'CSK_Module_OPCUAServer'
  }, 500);
})