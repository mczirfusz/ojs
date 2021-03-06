<?php

/**
 * @file plugins/generic/webFeed/SettingsForm.inc.php
 *
 * Copyright (c) 2014-2015 Simon Fraser University Library
 * Copyright (c) 2003-2015 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @class SettingsForm
 * @ingroup plugins_generic_webFeed
 *
 * @brief Form for managers to modify web feeds plugin settings
 */

import('lib.pkp.classes.form.Form');

class SettingsForm extends Form {

	/** @var int Associated context ID */
	private $_contextId;

	/** @var WebFeedPlugin Web feed plugin */
	private $_plugin;

	/**
	 * Constructor
	 * @param $plugin WebFeedPlugin Web feed plugin
	 * @param $contextId int Context ID
	 */
	function SettingsForm($plugin, $contextId) {
		$this->_contextId = $contextId;
		$this->_plugin = $plugin;

		parent::Form($plugin->getTemplatePath() . 'settingsForm.tpl');
		$this->addCheck(new FormValidatorPost($this));
	}

	/**
	 * Initialize form data.
	 */
	function initData() {
		$contextId = $this->_contextId;
		$plugin = $this->_plugin;

		$this->setData('displayPage', $plugin->getSetting($contextId, 'displayPage'));
		$this->setData('displayItems', $plugin->getSetting($contextId, 'displayItems'));
		$this->setData('recentItems', $plugin->getSetting($contextId, 'recentItems'));
	}

	/**
	 * Assign form data to user-submitted data.
	 */
	function readInputData() {
		$this->readUserVars(array('displayPage','displayItems','recentItems'));

		// check that recent items value is a positive integer
		if ((int) $this->getData('recentItems') <= 0) $this->setData('recentItems', '');

		// if recent items is selected, check that we have a value
		if ($this->getData('displayItems') == 'recent') {
			$this->addCheck(new FormValidator($this, 'recentItems', 'required', 'plugins.generic.webfeed.settings.recentItemsRequired'));
		}

	}

	/**
	 * Fetch the form.
	 * @copydoc Form::fetch()
	 */
	function fetch($request) {
		$templateMgr = TemplateManager::getManager($request);
		$templateMgr->assign('pluginName', $this->_plugin->getName());
		return parent::fetch($request);
	}

	/**
	 * Save settings. 
	 */
	function execute() {
		$plugin = $this->_plugin;
		$contextId = $this->_contextId;

		$plugin->updateSetting($contextId, 'displayPage', $this->getData('displayPage'));
		$plugin->updateSetting($contextId, 'displayItems', $this->getData('displayItems'));
		$plugin->updateSetting($contextId, 'recentItems', $this->getData('recentItems'));
	}
}

?>
