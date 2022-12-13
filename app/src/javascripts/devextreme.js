import Globalize from 'globalize';
import 'devextreme/localization/globalize/core';
import 'devextreme/localization/globalize/number';
import 'devextreme/localization/globalize/date';
import 'devextreme/localization/globalize/message';
import 'devextreme/localization/globalize/currency';
window.Globalize = Globalize;

import '../../assets/javascripts/data_table';
import '../../assets/javascripts/data_table_templates';
import '../../assets/javascripts/master_detail';
// When we have fixed the issue with "Fixed columns break sorting", then we can reference devextreme npm packages
// import 'devextreme/dist/js/dx.all.debug';
import '../../assets/javascripts/dx.webappjs';
