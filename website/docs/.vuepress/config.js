module.exports = {
  title: 'youwallet',
  description: 'Just playing around',
  displayAllHeaders: true, // 默认值：false
  markdown: {
    lineNumbers: true
  },
  themeConfig: {
    nav: [
      { text: '首页', link: '/' },
      { text: '合约介绍', link: '/token/' },
      { text: '接口', link: '/api/' },
      { text: '开发团队', link: '/team/' },
      { text: 'Github', link: 'https://github.com/youwallet/wallet/' },
    ],
    sidebar: {
	  	'/api/': [
	        '',     /* /foo/ */
	     ],
	}
  },
}