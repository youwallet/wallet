module.exports = {
  title: 'youwallet',
  description: 'Just playing around',
  displayAllHeaders: true, // 默认值：false
  themeConfig: {
    nav: [
      { text: '首页', link: '/' },
      { text: '接口', link: '/api/' },
      { text: 'Github', link: 'https://github.com/youwallet/wallet/' },
    ],
    sidebar: {
	  	'/api/': [
	        '',     /* /foo/ */
	     ],
	}
  },
}