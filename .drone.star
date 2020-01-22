config = {
	'app': 'graph-explorer',
	'rocketchat': {
		'channel': 'builds',
		'from_secret': 'private_rocketchat'
	},

	'branches': [
		'master',
		'release*',
		'develop*'
	],

	'yarnlint': True,

	'build': True
}

def main(ctx):
	before = beforePipelines(ctx)
	after = afterPipelines(ctx)

	return before + after

def beforePipelines(ctx):
	return yarnlint()

def afterPipelines(ctx):
	return build(ctx) + notify()

def yarnlint():
	pipelines = []

	if 'yarnlint' not in config:
		return pipelines

	if type(config['yarnlint']) == "bool":
		if not config['yarnlint']:
			return pipelines

	result = {
		'kind': 'pipeline',
		'type': 'docker',
		'name': 'lint-test',
		'workspace' : {
			'base': '/var/www/owncloud',
			'path': config['app']
		},
		'steps':
			installNPM() +
			lintTest() +
			buildExplorer(),
		'depends_on': [],
		'trigger': {
			'ref': [
				'refs/tags/**',
				'refs/pull/**',
				'refs/pull-requests/**',
				'refs/merge-requests/**',
			]
		}
	}

	for branch in config['branches']:
		result['trigger']['ref'].append('refs/heads/%s' % branch)

	pipelines.append(result)

	return pipelines

def build(ctx):
	pipelines = []

	if 'build' not in config:
		return pipelines

	if type(config['build']) == "bool":
		if not config['build']:
			return pipelines

	result = {
		'kind': 'pipeline',
		'type': 'docker',
		'name': 'publish-npm-and-demo-system',
		'workspace' : {
			'base': '/var/www/owncloud',
			'path': config['app']
		},
		'steps':
			installNPM() +
			buildExplorer() +
			buildRelease(ctx),
		'depends_on': [],
		'trigger': {
			'ref': [
				'refs/merge-requests/**',
				'refs/heads/master',
				'refs/tags/**',
			]
		}
	}

	pipelines.append(result)

	return pipelines

def notify():
	pipelines = []

	result = {
		'kind': 'pipeline',
		'type': 'docker',
		'name': 'chat-notifications',
		'clone': {
			'disable': True
		},
		'steps': [
			{
				'name': 'notify-rocketchat',
				'image': 'plugins/slack:1',
				'pull': 'always',
				'settings': {
					'webhook': {
						'from_secret': config['rocketchat']['from_secret']
					},
					'channel': config['rocketchat']['channel']
				}
			}
		],
		'depends_on': [],
		'trigger': {
			'ref': [
				'refs/tags/**'
			],
			'status': [
				'success',
				'failure'
			]
		}
	}

	for branch in config['branches']:
		result['trigger']['ref'].append('refs/heads/%s' % branch)

	pipelines.append(result)

	return pipelines

def installNPM():
	return [{
		'name': 'npm-install',
		'image': 'owncloudci/nodejs:10',
		'pull': 'always',
		'commands': [
			'npm install'
		]
	}]

def lintTest():
	return [{
		'name': 'lint-test',
		'image': 'owncloudci/nodejs:10',
		'pull': 'always',
		'commands': [
			'npm run lint'
		]
	}]

def buildExplorer():
	return [{
		'name': 'build',
		'image': 'owncloudci/nodejs:10',
		'pull': 'always',
		'commands': [
			'npm run build:prod'
		]
	}]

def buildRelease(ctx):
	return [
		{
			'name': 'release-to-github',
			'image': 'plugins/github-release:1',
			'pull': 'always',
			'settings': {
				'api_key': {
					'from_secret': 'github_token',
				},
				'files': [
					'dist/*',
				],
				'checksum': [
					'md5',
					'sha256'
				],
				'title': ctx.build.ref.replace("refs/tags/v", ""),
				'overwrite': True,
			},
			'when': {
				'ref': [
					'refs/tags/**',
				],
			}
		}
	]
