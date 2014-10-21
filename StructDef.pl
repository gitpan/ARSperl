

%EXPORT_VERSION = (
	'4.0.3' => '4L',
	'4.5.1' => '5L',
	'4.5.2' => '5L',
	'5.0.0' => '6L',
	'5.0.1' => '6L',
	'5.1.0' => '7L',
	'5.1.1' => '7L',
	'5.1.2' => '7L',
	'6.0.0' => '8L',
	'6.0.1' => '8L',
	'6.3.0' => '8L',
	'7.0.0' => '9L',
	'7.0.1' => '9L',
);

$CTRL_PREFIX = '_';
$INVD_PREFIX = '#';

%CONVERT = (
ARFieldLimitList => {
	_num  => 'p->numItems',
	_list => 'p->fieldLimitList',
	_type => 'ARFieldLimitStruct',
},
ARFieldLimitStruct => {
#	_typeparam => 1,
	_switch  => 'p->dataType',
#	_map     => 'DataTypeMap',
#	_switch  => 'p->dataType',
	_map => 'dataType',
	_case    => {
		AR_DATA_TYPE_INTEGER => {
			_type => 'ARIntegerLimitsStruct',
			_data => 'p->u.intLimits',
		},
		AR_DATA_TYPE_REAL => {
			_type => 'ARRealLimitsStruct',
			_data => 'p->u.realLimits',
		},
		AR_DATA_TYPE_CHAR => {
			_type => 'ARCharLimitsStruct',
			_data => 'p->u.charLimits',
		},
		AR_DATA_TYPE_DIARY => {
			_type => 'ARDiaryLimitsStruct',
			_data => 'p->u.diaryLimits',
		},
		AR_DATA_TYPE_ENUM => {
			_min_version => '5.0.0',
			_type => 'AREnumLimitsStruct',
			_data => 'p->u.enumLimits',
		},
		AR_DATA_TYPE_DECIMAL => {
			_type => 'ARDecimalLimitsStruct',
			_data => 'p->u.decimalLimits',
		},
		AR_DATA_TYPE_ATTACH => {
			_type => 'ARAttachLimitsStruct',
			_data => 'p->u.attachLimits',
		},
		AR_DATA_TYPE_CURRENCY => {
			_min_version => '5.1.0',
			_type => 'ARCurrencyLimitsStruct',
			_data => 'p->u.currencyLimits',
		},
		AR_DATA_TYPE_DATE => {
			_min_version => '5.1.0',
			_type => 'ARDateLimitsStruct',
			_data => 'p->u.dateLimits',
		},
		AR_DATA_TYPE_TABLE => {
			_type => 'ARTableLimitsStruct',
			_data => 'p->u.tableLimits',
		},
		AR_DATA_TYPE_COLUMN => {
			_type => 'ARColumnLimitsStruct',
			_data => 'p->u.columnLimits',
		},
		AR_DATA_TYPE_VIEW => {
			_min_version => '5.0.0',
			_type => 'ARViewLimits',
			_data => 'p->u.viewLimits',
		},
		AR_DATA_TYPE_DISPLAY => {
			_min_version => '5.0.0',
			_type => 'ARDisplayLimits',
			_data => 'p->u.displayLimits',
		},
	},
},
ARIntegerLimitsStruct => {
	min => {
		_type => 'long',
		_data => 'p->rangeLow',
	},
	max => {
		_type => 'long',
		_data => 'p->rangeHigh',
	},
},
ARRealLimitsStruct => {
	min => {
		_type => 'double',
		_data => 'p->rangeLow',
	},
	max => {
		_type => 'double',
		_data => 'p->rangeHigh',
	},
	precision => {
		_type => 'int',
		_data => 'p->precision',
	},
},
ARCharLimitsStruct => {
	maxLength => {
		_type => 'unsigned int',
		_data => 'p->maxLength',
	},
	menuStyle => {
		_type => 'unsigned int',
		_data => 'p->menuStyle',
		_map  => {
			AR_MENU_APPEND    => 'append',
			AR_MENU_OVERWRITE => 'overwrite',
		},
	},
	match => {
		_type => 'unsigned int',
		_data => 'p->qbeMatchOperation',
		_map  => {
			AR_QBE_MATCH_ANYWHERE => 'anywhere',
			AR_QBE_MATCH_LEADING  => 'leading',
			AR_QBE_MATCH_EQUAL    => 'equal',
		},
	},
	charMenu => {
		_type => 'ARNameType',
		_data => 'p->charMenu',
	},
	pattern => {
		_type => 'char*',
		_data => 'p->pattern',
	},
	fullTextOptions => {
		_type => 'unsigned int',
		_data => 'p->fullTextOptions',
		_map  => {
			AR_FULLTEXT_OPTIONS_NONE    => 'none',
			AR_FULLTEXT_OPTIONS_INDEXED => 'indexed',
		},
	},
},
ARDiaryLimitsStruct => {
	fullTextOptions => {
		_type => 'unsigned int',
		_data => 'p->fullTextOptions',
	},
},
AREnumLimitsStruct => {
	_min_version => '5.0.0',
	enumLimits => {
		_switch  => 'p->listStyle',
		_case    => {
			AR_ENUM_STYLE_REGULAR => {
				regularList => {
					_type => 'ARNameList',
					_data => 'p->u.regularList',
				},
			},
			AR_ENUM_STYLE_CUSTOM => {
				customList => {
					_type => 'AREnumItemList',
					_data => 'p->u.customList',
				},
			},
			AR_ENUM_STYLE_QUERY => {
				queryList => {
					_type => 'AREnumQueryStruct',
					_data => 'p->u.queryList',
				},
			},
		},
	},
},
ARAttachLimitsStruct => {
	maxSize => {
		_type => 'unsigned long',
		_data => 'p->maxSize',
	},
	attachType => {
		_type => 'unsigned int',
		_data => 'p->attachType',
	},
},
ARTableLimitsStruct => {
	numColumns => {
		_type => 'unsigned int',
		_data => 'p->numColumns',
	},
	qualifier => {
		_type => 'ARQualifierStruct',
		_data => 'p->qualifier',
	},
	maxRetrieve => {
		_type => 'unsigned int',
		_data => 'p->maxRetrieve',
	},
	schema => {
		_type => 'ARNameType',
		_data => 'p->schema',
	},
	server => {
		_type => 'ARServerNameType',
		_data => 'p->server',
	},
	sampleSchema => {
		_min_version => '6.0.0',
		_type => 'ARNameType',
		_data => 'p->sampleSchema',
	},
	sampleServer => {
		_min_version => '6.0.0',
		_type => 'ARServerNameType',
		_data => 'p->sampleServer',
	},
},
ARColumnLimitsStruct => {
	parent => {
		_type => 'ARInternalId',
		_data => 'p->parent',
	},
	dataField => {
		_type => 'ARInternalId',
		_data => 'p->dataField',
	},
	dataSource => {
		_type => 'unsigned int',
		_data => 'p->dataSource',
	},
	colLength => {
		_type => 'unsigned int',
		_data => 'p->colLength',
	},
},
ARDecimalLimitsStruct => {
	rangeLow => {
		_type => 'char*',
		_data => 'p->rangeLow',
	},
	rangeHigh => {
		_type => 'char*',
		_data => 'p->rangeHigh',
	},
	precision => {
		_type => 'int',
		_data => 'p->precision',
	},
},
ARViewLimits => {
	_min_version => '5.0.0',
	maxLength => {
		_type => 'unsigned int',
		_data => 'p->maxLength',
	},
},
ARDisplayLimits => {
	_min_version => '5.0.0',
	maxLength => {
		_type => 'unsigned int',
		_data => 'p->maxLength',
	},
},
ARDateLimitsStruct => {
	_min_version => '5.1.0',
	minDate => {
		_type => 'int',
		_data => 'p->minDate',
	},
	maxDate => {
		_type => 'int',
		_data => 'p->maxDate',
	},
},
ARCurrencyLimitsStruct => {
	_min_version => '5.1.0',
	rangeLow => {
		_type => 'char*',
		_data => 'p->rangeLow',
	},
	rangeHigh => {
		_type => 'char*',
		_data => 'p->rangeHigh',
	},
	precision => {
		_type => 'int',
		_data => 'p->precision',
	},
	functionalCurrencies => {
		_type => 'ARCurrencyDetailList',
		_data => 'p->functionalCurrencies',
	},
	allowableCurrencies => {
		_type => 'ARCurrencyDetailList',
		_data => 'p->allowableCurrencies',
	},
},
ARNameList => {
	_num  => 'p->numItems',
	_list => 'p->nameList',
	_type => 'ARNameType',
},
ARCurrencyDetailList => {
	_min_version => '5.1.0',
	_num  => 'p->numItems',
	_list => 'p->currencyDetailList',
	_type => 'ARCurrencyDetailStruct',
},
ARCurrencyDetailStruct => {
	_min_version => '5.1.0',
	currencyCode => {
		_type => 'ARCurrencyCodeType',
		_data => 'p->currencyCode',
	},
	precision => {
		_type => 'int',
		_data => 'p->precision',
	},
},
AREnumItemList => {
	_min_version => '5.0.0',
	_num  => 'p->numItems',
	_list => 'p->enumItemList',
	_type => 'AREnumItemStruct',
},
AREnumQueryStruct => {
	_min_version => '5.0.0',
	schema => {
		_type => 'ARNameType',
		_data => 'p->schema',
	},
	server => {
		_type => 'char[AR_MAX_SERVER_SIZE+1]',
		_data => 'p->server',
	},
	qualifier => {
		_type => 'ARQualifierStruct',
		_data => 'p->qualifier',
	},
	nameField => {
		_type => 'ARInternalId',
		_data => 'p->nameField',
	},
	numberField => {
		_type => 'ARInternalId',
		_data => 'p->numberField',
	},
},
AREnumItemStruct => {
	_min_version => '5.0.0',
	itemName => {
		_type => 'ARNameType',
		_data => 'p->itemName',
	},
	itemNumber => {
		_type => 'unsigned long',
		_data => 'p->itemNumber',
	},
},
ARInternalId => {
	_typedef => 'unsigned long',
},
ARNameType => {
	_typedef => 'char[AR_MAX_NAME_SIZE+1]',
},
ARServerNameType => {
	_typedef => 'char[AR_MAX_SERVER_SIZE+1]',
},
ARCurrencyCodeType => {
	_min_version => '5.1.0',
	_typedef => 'char[AR_MAX_CURRENCY_CODE_SIZE+1]',
},

ARFieldMappingList => {
	_num  => 'p->numItems',
	_list => 'p->mappingList',
	_type => 'ARFieldMappingStruct',
},
ARFieldMappingStruct => {
	_switch  => 'p->fieldType',
#	_default =>	'AR_FIELD_REGULAR',
	_map => [ 'fieldType', {
		AR_FIELD_NONE    => 0,
		AR_FIELD_REGULAR => 1,
		AR_FIELD_JOIN    => 2,
		AR_FIELD_VIEW    => 3,
		AR_FIELD_VENDOR  => 4,
		AR_FIELD_INHERITANCE => 5,
	} ],
	_case => {
		AR_FIELD_NONE => {
			_nodata => 1,
		},
		AR_FIELD_REGULAR => {
			_nodata => 1,
		},
		AR_FIELD_JOIN => {
			'join' => {
				_type => 'ARJoinMappingStruct',
				_data => 'p->u.join',
			},
		},
		AR_FIELD_VIEW => {
			view => {
				_type => 'ARViewMappingStruct',
				_data => 'p->u.view',
			},
		},
		AR_FIELD_VENDOR => {
			_min_version => '5.0.0',
			vendor => {
				_type => 'ARVendorMappingStruct',
				_data => 'p->u.vendor',
			},
		},
		AR_FIELD_INHERITANCE => {
			_min_version => '6.0.0',
			inheritance => {
				_type => 'ARInheritanceMappingStruct',
				_data => 'p->u.inheritance',
			},
		},
	},
},

ARJoinMappingStruct => {
	schemaIndex => {
		_type => 'unsigned int',
		_data => 'p->schemaIndex',
	},
	realId => {
		_type => 'ARInternalId',
		_data => 'p->realId',
	},
},
ARViewMappingStruct => {
	fieldName => {
		_type => 'ARNameType',
		_data => 'p->fieldName',
	},
},
ARVendorMappingStruct => {
	_min_version => '5.0.0',
	fieldName => {
		_type => 'ARNameType',
		_data => 'p->fieldName',
	},
},
ARInheritanceMappingStruct => {
	_min_version => '6.0.0',
	srcSchema => {
		_type => 'ARNameType',
		_data => 'p->srcSchema',
	},
	referenceMask => {
		_type => 'unsigned int',
		_data => 'p->referenceMask',
	},
	dataMappingId => {
		_type => 'unsigned int',
		_data => 'p->dataMappingId',
	},
},


ARQualifierStruct => {
	_switch => 'p->operation',
	_map => [ 'oper', {
		AR_COND_OP_AND => 'and',
		AR_COND_OP_OR  => 'or',
		AR_COND_OP_NOT => 'not',
		AR_COND_OP_REL_OP     => 'rel_op',
		AR_COND_OP_FROM_FIELD => 'external',
	} ],
	_case => {
		AR_COND_OP_NONE => {
			_default => 1,
		},
		AR_COND_OP_AND  => {
			left => {
				_type => 'ARQualifierStruct*',
				_data => 'p->u.andor.operandLeft',
			},
			right => {
				_type => 'ARQualifierStruct*',
				_data => 'p->u.andor.operandRight',
			},
		},
		AR_COND_OP_OR => {
			left => {
				_type => 'ARQualifierStruct*',
				_data => 'p->u.andor.operandLeft',
			},
			right => {
				_type => 'ARQualifierStruct*',
				_data => 'p->u.andor.operandRight',
			},
		},
		AR_COND_OP_NOT => {
			'not' => {
				_type => 'ARQualifierStruct*',
				_data => 'p->u.not',
			},
		},
		AR_COND_OP_REL_OP => {
			rel_op => {
				_type => 'ARRelOpStruct*',
				_data => 'p->u.relOp',
			}
		},
		AR_COND_OP_FROM_FIELD => {
			fieldId => {
				_type => 'ARInternalId',
				_data => 'p->u.fieldId',
			},
		},
	},
},
ARRelOpStruct => {
	oper => {
		_type => 'unsigned int',
		_data => 'p->operation',
		_map  => {
			AR_REL_OP_EQUAL         => '==',
			AR_REL_OP_GREATER       => '>',
			AR_REL_OP_GREATER_EQUAL => '>=',
			AR_REL_OP_LESS          => '<',
			AR_REL_OP_LESS_EQUAL    => '<=',
			AR_REL_OP_NOT_EQUAL     => '!=',
			AR_REL_OP_LIKE          => 'like',
			AR_REL_OP_IN            => 'in',
		},
	},
	left => {
		_type => 'ARFieldValueOrArithStruct',
		_data => 'p->operandLeft',
	},
	right => {
		_type => 'ARFieldValueOrArithStruct',
		_data => 'p->operandRight',
	},
},
ARFieldValueOrArithStruct => {
	_switch => 'p->tag',
	_case => {
		AR_FIELD => {
			fieldId => {
				_type => 'ARInternalId',
				_data => 'p->u.fieldId',
			},
		},
		AR_VALUE => {
			value => {
				_type => 'ARValueStruct',
				_data => 'p->u.value',
			},
		},
		AR_ARITHMETIC => {
			arith => {
				_type => 'ARArithOpStruct*',
				_data => 'p->u.arithOp',
			},
		},
		AR_STAT_HISTORY => {
			statHistory => {
				_type => 'ARStatHistoryValue',
				_data => 'p->u.statHistory',
			},
		},
		AR_VALUE_SET => {
			valueSet => {
				_type => 'ARValueList',
				_data => 'p->u.valueSet',
			},
		},
		AR_CURRENCY_FLD => {
			_min_version => '5.1.0',
			currencyField => {
				_type => 'ARCurrencyPartStruct*',
				_data => 'p->u.currencyField',
			},
		},
		AR_FIELD_TRAN => {
			TR_fieldId => {
				_type => 'ARInternalId',
				_data => 'p->u.fieldId',
			},
		},
		AR_FIELD_DB => {
			DB_fieldId => {
				_type => 'ARInternalId',
				_data => 'p->u.fieldId',
			},
		},
		AR_LOCAL_VARIABLE => {
			variable => {
				_type => 'unsigned int',
				_data => 'p->u.variable',
			},
		},
		AR_QUERY => {
			queryValue => {
				_type => 'ARQueryValueStruct*',
				_data => 'p->u.queryValue',
			},			
		},
		AR_FIELD_CURRENT => {
			queryCurrent => {
				_type => 'ARInternalId',
			 	_data => 'p->u.fieldId',
			},
		},
	},
},
ARArithOpStruct => {
	oper => {
		_type => 'unsigned int',
		_data => 'p->operation',
		_map  => {
			AR_ARITH_OP_ADD      => '+',
			AR_ARITH_OP_SUBTRACT => '-',
			AR_ARITH_OP_MULTIPLY => '*',
			AR_ARITH_OP_DIVIDE   => '/',
			AR_ARITH_OP_MODULO   => '%',
			AR_ARITH_OP_NEGATE   => '-',
		},
	},
	left => {
		_type => 'ARFieldValueOrArithStruct',
		_data => 'p->operandLeft',
	},
	right => {
		_type => 'ARFieldValueOrArithStruct',
		_data => 'p->operandRight',
	},
},
ARStatHistoryValue => {
	_header_only => 1,
	enumVal => {
		_type => 'unsigned long',
		_data => 'p->enumVal',
	},
	userOrTime => {
		_type => 'unsigned int',
		_data => 'p->userOrTime',
	},
},
ARQueryValueStruct => {
	schema => {
		_type => 'ARNameType',
		_data => 'p->schema',
	},
	server => {
		_type => 'char[AR_MAX_SERVER_SIZE+1]',
		_data => 'p->server',
	},
	qualifier => {
		_type => 'ARQualifierStruct*',
		_data => 'p->qualifier',
	},
	valueField => {
		_type => 'ARInternalId',
		_data => 'p->valueField',
	},
	multi => {
		_type => 'unsigned int',
		_data => 'p->multiMatchCode',
		_map  => {
			AR_QUERY_VALUE_MULTI_ERROR => 'error',
			AR_QUERY_VALUE_MULTI_FIRST => 'first',
			AR_QUERY_VALUE_MULTI_SET   => 'set',
		},
	},
},
ARValueList => {
	_num  => 'p->numItems',
	_list => 'p->valueList',
	_type => 'ARValueStruct',
},
ARValueStruct => {
	_typeparam   => 1,
	_header_only => 1,
},

ARCompoundSchemaList => {
	_num  => 'p->numItems',
	_list => 'p->compoundSchema',
	_type => 'ARCompoundSchema',
},
ARCompoundSchema => {
	_switch => 'p->schemaType',
	_map => [ 'schemaType', {
		AR_SCHEMA_REGULAR => 'regular',
		AR_SCHEMA_JOIN    => 'join',
		AR_SCHEMA_VIEW    => 'view',
		AR_SCHEMA_DIALOG  => 'dialog',
		AR_SCHEMA_VENDOR  => 'vendor',
	} ],
	_case => {
		AR_SCHEMA_REGULAR => {
			_nodata => 1,
		},
		AR_SCHEMA_DIALOG => {
			_nodata => 1,
		},
		AR_SCHEMA_JOIN => {
			'join' => {
				_type => 'ARJoinSchema',
				_data => 'p->u.join',
			},
		},
		AR_SCHEMA_VIEW => {
			view => {
				_type => 'ARViewSchema',
				_data => 'p->u.view',
			},
		},
		AR_SCHEMA_VENDOR => {
			_min_version => '5.0.0',
			vendor => {
				_type => 'ARVendorSchema',
				_data => 'p->u.vendor',
			},
		},
	},
},
ARJoinSchema => {
	memberA => {
		_type => 'ARNameType',
		_data => 'p->memberA',
	},
	memberB => {
		_type => 'ARNameType',
		_data => 'p->memberB',
	},
	joinQual => {
		_type => 'ARQualifierStruct',
		_data => 'p->joinQual',
	},
	option => {
		_type => 'unsigned int',
		_data => 'p->option',
	},
},
ARViewSchema => {
	tableName => {
		_type => 'char[AR_MAX_TABLENAME_SIZE+1]',
		_data => 'p->tableName',
	},
	keyField => {
		_type => 'ARNameType',
		_data => 'p->keyField',
	},
},
ARVendorSchema => {
	_min_version => '5.0.0',
	vendorName => {
		_type => 'ARNameType',
		_data => 'p->vendorName',
	},
	tableName => {
		_type => 'char[AR_MAX_TABLENAME_SIZE+1]',
		_data => 'p->tableName',
	},
},

AREntryListFieldList => {
	_num  => 'p->numItems',
	_list => 'p->fieldsList',
	_type => 'AREntryListFieldStruct',
},
AREntryListFieldStruct => {
	fieldId => {
		_type => 'ARInternalId',
		_data => 'p->fieldId',
	},
	columnWidth => {
		_type => 'unsigned int',
		_data => 'p->columnWidth',
	},
	separator => {
		_type => 'char[10]',
		_data => 'p->separator',
	},
},

ARSortList => {
	_num  => 'p->numItems',
	_list => 'p->sortList',
	_type => 'ARSortStruct',
},
ARSortStruct => {
	fieldId => {
		_type => 'ARInternalId',
		_data => 'p->fieldId',
	},
	sortOrder => {
		_type => 'unsigned int',
		_data => 'p->sortOrder',
	},
},

ARIndexList => {
	_num  => 'p->numItems',
	_list => 'p->indexList',
	_type => 'ARIndexStruct',
},
ARIndexStruct => {
	fieldIds => {
		_num  => 'p->numFields',
		_list => 'p->fieldIds',
		_type => 'ARInternalId[]',
	},
	unique => {
		_type => 'ARBoolean',
		_data => 'p->unique',
		_default => 'FALSE',
	},
#	indexName => {
#		_type => 'ARNameType',
#		_data => 'p->indexName',
#	},
#	dataMappingUsageCnt => {
#		_type => 'unsigned int',
#		_data => 'p->dataMappingUsageCnt',
#	},
},

ARBoolean => {
	_typedef => 'unsigned char',
},

ARDayStruct => {
	monthday => {
		_type => 'long',
		_data => 'p->monthday',
	},
	weekday => {
		_type => 'long',
		_data => 'p->weekday',
	},
	hourmask => {
		_type => 'long',
		_data => 'p->hourmask',
	},
	minute => {
		_type => 'unsigned int',
		_data => 'p->minute',
	},
},

ARContainerOwnerObjList => {
	_num  => 'p->numItems',
	_list => 'p->ownerObjList',
	_type => 'ARContainerOwnerObj',
},
ARReferenceList => {
	_num  => 'p->numItems',
	_list => 'p->referenceList',
	_type => 'ARReferenceStruct',
},
ARContainerOwnerObj => {
	type => {
		_type => 'unsigned int',
		_data => 'p->type',
		_map  => {
			ARCONOWNER_NONE   => 'none',
			ARCONOWNER_ALL    => 'all',
			ARCONOWNER_SCHEMA => 'schema',
		},
	},
	ownerName => {
		_type => 'ARNameType',
		_data => 'p->ownerName',
	},
},
ARPushFieldsActionStruct => {
	_min_version => '6.0.0',
	pushFieldsList => {
		_type => 'ARPushFieldsList',
		_data => 'p->pushFieldsList',
	},
	sampleServer => {
		_type => 'ARServerNameType',
		_data => 'p->sampleServer',
	},
	sampleSchema => {
		_type => 'ARNameType',
		_data => 'p->sampleSchema',
	},
},
AROpenDlgStruct => {
	serverName => {
		_type => 'ARServerNameType',
		_data => 'p->serverName',
	},
	schemaName => {
		_type => 'ARNameType',
		_data => 'p->schemaName',
	},
	vuiLabel => {
		_type => 'ARNameType',
		_data => 'p->vuiLabel',
	},
	closeBox => {
		_map  => {
			FALSE => 'false',
			TRUE  => 'true',
		},
		_type => 'ARBoolean',
		_data => 'p->closeBox',
	},
	inputValueFieldPairs => {
		_type => 'ARFieldAssignList',
		_data => 'p->inputValueFieldPairs',
	},
	outputValueFieldPairs => {
		_type => 'ARFieldAssignList',
		_data => 'p->outputValueFieldPairs',
	},
	windowMode => {
		_max_version => '5.1.2',
		_map => {
			AR_ACTIVE_LINK_ACTION_OPEN_DLG           => "open_dlg",
			AR_ACTIVE_LINK_ACTION_OPEN_SEARCH        => "open_search",
			AR_ACTIVE_LINK_ACTION_OPEN_SUBMIT        => "open_submit",
			AR_ACTIVE_LINK_ACTION_OPEN_MODIFY_LST    => "open_modify_lst",
			AR_ACTIVE_LINK_ACTION_OPEN_MODIFY_DETAIL => "open_modify_detail",
			AR_ACTIVE_LINK_ACTION_OPEN_MODIFY_SPLIT  => "open_modify_split",
			AR_ACTIVE_LINK_ACTION_OPEN_DSPLY_LST     => "open_dsply_lst",
			AR_ACTIVE_LINK_ACTION_OPEN_DSPLY_DETAIL  => "open_dsply_detail",
			AR_ACTIVE_LINK_ACTION_OPEN_DSPLY_SPLIT   => "open_dsply_split",
			AR_ACTIVE_LINK_ACTION_OPEN_REPORT        => "open_report",
		},
		_type => 'int',
		_data => 'p->windowMode',
	},
	'windowMode+' => {
		_min_version => '6.0.0',
		_map => {
			AR_ACTIVE_LINK_ACTION_OPEN_DLG           => "open_dlg",
			AR_ACTIVE_LINK_ACTION_OPEN_SEARCH        => "open_search",
			AR_ACTIVE_LINK_ACTION_OPEN_SUBMIT        => "open_submit",
			AR_ACTIVE_LINK_ACTION_OPEN_MODIFY_LST    => "open_modify_lst",
			AR_ACTIVE_LINK_ACTION_OPEN_MODIFY_DETAIL => "open_modify_detail",
			AR_ACTIVE_LINK_ACTION_OPEN_MODIFY_SPLIT  => "open_modify_split",
			AR_ACTIVE_LINK_ACTION_OPEN_DSPLY_LST     => "open_dsply_lst",
			AR_ACTIVE_LINK_ACTION_OPEN_DSPLY_DETAIL  => "open_dsply_detail",
			AR_ACTIVE_LINK_ACTION_OPEN_DSPLY_SPLIT   => "open_dsply_split",
			AR_ACTIVE_LINK_ACTION_OPEN_REPORT        => "open_report",
			AR_ACTIVE_LINK_ACTION_OPEN_MODIFY        => "open_modify",
			AR_ACTIVE_LINK_ACTION_OPEN_DSPLY         => "open_dsply",
		},
		_type => 'int',
		_data => 'p->windowMode',
	},
	targetLocation => {
		_type => 'char *',
		_data => 'p->targetLocation',
	},
	query => {
		_type => 'ARQualifierStruct',
		_data => 'p->query',
	},
	noMatchContinue => {
		_map  => {
			FALSE => 'false',
			TRUE  => 'true',
		},
		_type => 'ARBoolean',
		_data => 'p->noMatchContinue',
	},
	suppressEmptyList => {
		_map  => {
			FALSE => 'false',
			TRUE  => 'true',
		},
		_type => 'ARBoolean',
		_data => 'p->suppressEmptyLst',
	},
	message => {
		_type => 'ARMessageStruct',
		_data => 'p->msg',
	},
	pollinginterval => {
		_type => 'ARULong32',
		_data => 'p->pollinginterval',
	},
	reportString => {
		_type => 'char *',
		_data => 'p->reportString',
	},
	sortOrderList => {
		_type => 'ARSortList',
		_data => 'p->sortOrderList',
	},
},
ARCloseWndStruct => {
	closeAll => {
		_map  => {
			FALSE => 'false',
			TRUE  => 'true',
		},
		_type => 'ARBoolean',
		_data => 'p->closeAll',
	},
},
ARCommitChangesStruct => {
	schemaName => {
		_type => 'ARNameType',
		_data => 'p->schemaName',
	},
},
ARCallGuideStruct => {
	serverName => {
		_type => 'ARServerNameType',
		_data => 'p->serverName',
	},
	guideName => {
		_type => 'ARNameType',
		_data => 'p->guideName',
	},
	guideMode => {
		_type => 'int',
		_data => 'p->guideMode',
	},
	loopTable => {
		_type => 'ARInternalId',
		_data => 'p->guideTableId',
	},
	inputValueFieldPairs => {
		_min_version => '6.0.0',
		_type => 'ARFieldAssignList',
		_data => 'p->inputValueFieldPairs',
	},
	outputValueFieldPairs => {
		_min_version => '6.0.0',
		_type => 'ARFieldAssignList',
		_data => 'p->outputValueFieldPairs',
	},
	sampleServer => {
		_min_version => '6.0.0',
		_type => 'ARServerNameType',
		_data => 'p->sampleServer',
	},
	sampleGuide => {
		_min_version => '6.0.0',
		_type => 'ARNameType',
		_data => 'p->sampleGuide',
	},
},
ARExitGuideStruct => {
	closeAll => {
		_map  => {
			FALSE => 'false',
			TRUE  => 'true',
		},
		_type => 'ARBoolean',
		_data => 'p->closeAll',
	},
},
ARGotoGuideLabelStruct => {
	label => {
		_type => 'char *',
		_data => 'p->label',
	},
},
ARGotoActionStruct => {
	tag => {
		_type => 'unsigned int',
		_data => 'p->tag',
	},
	fieldIdOrValue => {
		_type => 'ARULong32',
		_data => 'p->fieldIdOrValue',
	},
},
ARWaitStruct => {
	continueButtonTitle => {
		_type => 'char *',
		_data => 'p->continueButtonTitle',
	},
},
ARDDEStruct => {
	serviceName => {
		_type => 'char *',
		_data => 'p->serviceName',
	},
	topic => {
		_type => 'char *',
		_data => 'p->topic',
	},
	action => {
		_type => 'unsigned int',
		_data => 'p->action',
	},
	pathToProgram => {
		_type => 'char *',
		_data => 'p->pathToProgram',
	},
	command => {
		_type => 'char *',
		_data => 'p->command',
	},
	item => {
		_type => 'char *',
		_data => 'p->item',
	},
},
ARAutomationStruct => {
	autoServerName => {
		_type => 'char *',
		_data => 'p->autoServerName',
	},
	clsId => {
		_type => 'char *',
		_data => 'p->clsId',
	},
	action => {
		_type => 'char *',
		_data => 'p->action',
	},
	isVisible => {
		_map  => {
			FALSE => 'false',
			TRUE  => 'true',
		},
		_type => 'ARBoolean',
		_data => 'p->isVisible',
	},
	methodList => {
		_type => 'ARCOMMethodList',
		_data => 'p->methodList',
	},
},
ARCOMMethodList => {
	_num  => 'p->numItems',
	_list => 'p->methodList',
	_type => 'ARCOMMethodStruct',
},
ARCOMMethodStruct => {
	methodName => {
		_type => 'char *',
		_data => 'p->methodName',
	},
	methodIId => {
		_type => 'char *',
		_data => 'p->methodIId',
	},
	methodType => {
		_type => 'unsigned int',
		_data => 'p->methodType',
	},
	methodValue => {
		_type => 'ARCOMValueStruct',
		_data => 'p->methodValue',
	},
	parameterList => {
		_type => 'ARCOMMethodParmList',
		_data => 'p->parameterList',
	},
},
ARCOMValueStruct => {
	valueIId => {
		_type => 'char *',
		_data => 'p->valueIId',
	},
	transId => {
		_type => 'ARInternalId',
		_data => 'p->transId',
	},
	valueType => {
		_type => 'unsigned int',
		_data => 'p->valueType',
	},
	_switch => 'p->valueType',
	_map => {
		AR_COM_PARM_NULL    => 'null',
		AR_COM_PARM_FIELDID => 'fieldid',
		AR_COM_PARM_VALUE   => 'value',
	},
	_case => {
		AR_COM_PARM_NULL => {
			_default => 1,
		},
		AR_COM_PARM_FIELDID => {
			fieldId => {
				_type => 'ARInternalId',
				_data => 'p->u.fieldId',
			}
		},
		AR_COM_PARM_VALUE => {
			value => {
				_type => 'ARValueStruct',
				_data => 'p->u.value',
			},
		},
	},
},
ARCOMMethodParmList => {
	_num  => 'p->numItems',
	_list => 'p->parameterList',
	_type => 'ARCOMMethodParmStruct',
},
ARCOMMethodParmStruct => {
	parmName => {
		_type => 'char *',
		_data => 'p->parmName',
	},
	parmType => {
		_type => 'unsigned int',
		_data => 'p->parmType',
	},
	parmValue => {
		_type => 'ARCOMValueStruct',
		_data => 'p->parmValue',
	},
},
ARULong32 => {
	_typedef => 'unsigned long',
},
ARLong32 => {
	_typedef => 'long',
},
ARPushFieldsList => {
	_num  => 'p->numItems',
	_list => 'p->pushFieldsList',
	_type => 'ARPushFieldsStruct',
},
ARPushFieldsStruct => {
	field => {
		_type => 'ARAssignFieldStruct',
		_data => 'p->field',
	},
	assign => {
		_type => 'ARAssignStruct',
		_data => 'p->assign',
	},
},
ARCurrencyPartStruct => {
	_min_version => '5.1.0',
	fieldId => {
		_type => 'ARInternalId',
		_data => 'p->fieldId',
	},
	partTag => {
		_type => 'unsigned int',
		_data => 'p->partTag',
	},
	currencyCode => {
		_type => 'ARCurrencyCodeType',
		_data => 'p->currencyCode',
	},
},
ARFilterActionList => {
	_num  => 'p->numItems',
	_list => 'p->actionList',
	_type => 'ARFilterActionStruct',
},
ARFilterActionStruct => {
	_switch  => 'p->action',
	_map => {
		AR_FILTER_ACTION_NONE           => 'none',
		AR_FILTER_ACTION_NOTIFY         => 'notify',
		AR_FILTER_ACTION_MESSAGE        => 'message',
		AR_FILTER_ACTION_LOG            => 'log',
		AR_FILTER_ACTION_FIELDS         => 'assign_fields',
		AR_FILTER_ACTION_PROCESS        => 'process',
		AR_FILTER_ACTION_FIELDP         => 'fieldp',
		AR_FILTER_ACTION_SQL            => 'sqlCommand',
		AR_FILTER_ACTION_GOTOACTION     => 'gotoAction',
		AR_FILTER_ACTION_CALLGUIDE      => 'callGuide',
		AR_FILTER_ACTION_EXITGUIDE      => 'exitGuide',
		AR_FILTER_ACTION_GOTOGUIDELABEL => 'gotoGuide',
	},
	_case    => {
		AR_FILTER_ACTION_NONE => {
			_default => 1,
		},
		AR_FILTER_ACTION_NOTIFY => {
			notify => {
				_type => 'ARFilterActionNotify',
				_data => 'p->u.notify',
			},
		},
		AR_FILTER_ACTION_MESSAGE => {
			message => {
				_type => 'ARFilterStatusStruct',
				_data => 'p->u.message',
			},
		},
		AR_FILTER_ACTION_LOG => {
			log => {
				_type => 'char*',
				_data => 'p->u.logFile',
			},
		},
		AR_FILTER_ACTION_FIELDS => {
			_min_version => '6.0.0',
			assign_fields => {
				_type => 'ARSetFieldsActionStruct',
				_data => 'p->u.setFields',
			},
		},
		'AR_FILTER_ACTION_FIELDS+' => {
			_max_version => '5.1.2',
			assign_fields => {
				_type => 'ARFieldAssignList',
				_data => 'p->u.fieldList',
			},
		},
		AR_FILTER_ACTION_PROCESS => {
			process => {
				_type => 'char*',
				_data => 'p->u.process',
			},
		},
		AR_FILTER_ACTION_FIELDP => {
			_min_version => '6.0.0',
			fieldp => {
				_type => 'ARPushFieldsActionStruct',
				_data => 'p->u.pushFields',
			},
		},
		'AR_FILTER_ACTION_FIELDP+' => {
			_max_version => '5.1.2',
			fieldp => {
				_type => 'ARPushFieldsList',
				_data => 'p->u.pushFieldsList',
			},
		},
		AR_FILTER_ACTION_SQL => {
			sqlCommand => {
				_type => 'ARSQLStruct',
				_data => 'p->u.sqlCommand',
			},
		},
		AR_FILTER_ACTION_GOTOACTION => {
			gotoAction => {
				_type => 'ARGotoActionStruct',
				_data => 'p->u.gotoAction',
			},
		},
		AR_FILTER_ACTION_CALLGUIDE => {
			callGuide => {
				_type => 'ARCallGuideStruct',
				_data => 'p->u.callGuide',
			},
		},
		AR_FILTER_ACTION_EXITGUIDE => {
			exitGuide => {
				_type => 'ARExitGuideStruct',
				_data => 'p->u.exitGuide',
			},
		},
		AR_FILTER_ACTION_GOTOGUIDELABEL => {
			gotoGuide => {
				_type => 'char*',
				_data => 'p->u.gotoGuide.label',
			},
		},
	},
},
ARFilterActionNotify => {
	user => {
		_type => 'char *',
		_data => 'p->user',
	},
	notifyText => {
		_type => 'char *',
		_data => 'p->notifyText',
	},
	notifyPriority => {
		_type => 'unsigned int',
		_data => 'p->notifyPriority',
	},
	notifyMechanism => {
		_type => 'unsigned int',
		_data => 'p->notifyMechanism',
	},
	notifyMechanismXRef => {
		_type => 'ARInternalId',
		_data => 'p->notifyMechanismXRef',
	},
	subjectText => {
		_type => 'char *',
		_data => 'p->subjectText',
	},
	fieldIdListType => {
		_type => 'unsigned int',
		_data => 'p->fieldIdListType',
	},
	fieldList => {
		_type => 'ARInternalIdList',
		_data => 'p->fieldIdList',
	},
	notifyBehavior => {
		_min_version => '5.1.0',
		_type => 'unsigned int',
		_data => 'p->notifyBehavior',
	},
	notifyPermission => {
		_min_version => '5.1.0',
		_type => 'unsigned int',
		_data => 'p->notifyPermission',
	},
	notifyAdvanced => {
		_min_version => '5.1.0',
		_type    => 'ARFilterActionNotifyAdvanced*',
		_data    => 'p->notifyAdvanced',
		_default => 'NULL',
	},
},
ARSetFieldsActionStruct => {
	_min_version => '6.0.0',
	fieldList => {
		_type => 'ARFieldAssignList',
		_data => 'p->fieldList',
	},
	sampleServer => {
		_type => 'ARServerNameType',
		_data => 'p->sampleServer',
	},
	sampleSchema => {
		_type => 'ARNameType',
		_data => 'p->sampleSchema',
	},
},
ARSQLStruct => {
	server => {
		_type => 'char[AR_MAX_SERVER_SIZE+1]',
		_data => 'p->server',
	},
	command => {
		_type => 'char *',
		_data => 'p->command',
	},
},
ARFilterActionNotifyAdvanced => {
	_min_version => '5.1.0',
	from => {
		_type => 'char *',
		_data => 'p->from',
	},
	replyTo => {
		_type => 'char *',
		_data => 'p->replyTo',
	},
	cc => {
		_type => 'char *',
		_data => 'p->cc',
	},
	bcc => {
		_type => 'char *',
		_data => 'p->bcc',
	},
	organization => {
		_type => 'char *',
		_data => 'p->organization',
	},
	mailboxName => {
		_type => 'char *',
		_data => 'p->mailboxName',
	},
	headerTemplate => {
		_type => 'char *',
		_data => 'p->headerTemplate',
	},
	footerTemplate => {
		_type => 'char *',
		_data => 'p->footerTemplate',
	},
	contentTemplate => {
		_type => 'char *',
		_data => 'p->contentTemplate',
	},
#	reserved1 => {
#		_type => 'ARULong32',
#		_data => 'p->reserved1',
#	},
#	reserved2 => {
#		_type => 'ARULong32',
#		_data => 'p->reserved2',
#	},
#	reserved3 => {
#		_type => 'ARULong32',
#		_data => 'p->reserved3',
#	},
},
AREscalationTmStruct => {
	_switch => 'p->escalationTmType',
	_case => {
		AR_ESCALATION_TYPE_INTERVAL => {
			exitGuide => {
				_type => 'ARLong32',
				_data => 'p->u.interval',
			},
		},
		AR_ESCALATION_TYPE_TIMEMARK => {
			exitGuide => {
				_type => 'ARDayStruct',
				_data => 'p->u.date',
			},
		},
	},
},
ARUnsignedIntList => {
	_num  => 'p->numItems',
	_list => 'p->intList',
	_type => 'unsigned int',
},

AREntryListFieldValueList => {
	_num  => 'p->numItems',
	_list => 'p->entryList',
	_type => 'AREntryListFieldValueStruct',
},
AREntryListFieldValueStruct => {
	entryId => {
		_type => 'AREntryIdList',
		_data => 'p->entryId',
	},
	entryValues => {
		_type => 'ARFieldValueList*',
		_data => 'p->entryValues',
	},
},
AREntryIdList => {
	_num  => 'p->numItems',
	_list => 'p->entryIdList',
	_type => 'AREntryIdType',
},
ARFieldValueList => {
	_num  => 'p->numItems',
	_list => 'p->fieldValueList',
	_type => 'ARFieldValueStruct',
},
ARFieldValueStruct => {
	fieldId => {
		_type => 'ARInternalId',
		_data => 'p->fieldId',
	},
	value => {
		_type => 'ARValueStruct',
		_data => 'p->value',
	},
},

AREntryIdType => {
	_typedef => 'char[AR_MAX_ENTRYID_SIZE+1]',
},
ARAuditInfoStruct => {
	_min_version => '7.0.0',
	enable => {
		_type => 'unsigned int',
		_data => 'p->enable',
	},
	style => {
		_type => 'unsigned int',
		_data => 'p->style',
	},
	formName => {
		_type => 'ARNameType',
		_data => 'p->formName',
	},
	query => {
		_type => 'ARQualifierStruct',
		_data => 'p->query',
	},
},


ARBulkEntryReturnList => {
	_min_version => '7.0.0',
	_num  => 'p->numItems',
	_list => 'p->entryReturnList',
	_type => 'ARBulkEntryReturn',
},
ARBulkEntryReturn => {
	_min_version => '7.0.0',
	_switch => 'p->entryCallType',
	_case => {
		AR_BULK_ENTRY_CREATE => {
			createEntryReturn => {
				_type => 'AREntryReturn',
				_data => 'p->u.createEntryReturn',
			},
		},
		AR_BULK_ENTRY_SET => {
			setEntryReturn => {
				_type => 'ARStatusList',
				_data => 'p->u.setEntryReturn',
			},
		},
		AR_BULK_ENTRY_DELETE => {
			deleteEntryReturn => {
				_type => 'ARStatusList',
				_data => 'p->u.deleteEntryReturn',
			},
		},
		AR_BULK_ENTRY_MERGE => {
			mergeEntryReturn => {
				_type => 'AREntryReturn',
				_data => 'p->u.mergeEntryReturn',
			},
		},
		AR_BULK_ENTRY_XMLCREATE => {
			xmlCreateEntryReturn => {
				_type => 'ARXMLEntryReturn',
				_data => 'p->u.xmlCreateEntryReturn',
			},
		},
		AR_BULK_ENTRY_XMLSET => {
			xmlSetEntryReturn => {
				_type => 'ARXMLEntryReturn',
				_data => 'p->u.xmlSetEntryReturn',
			},
		},
		AR_BULK_ENTRY_XMLDELETE => {
			xmlDeleteEntryReturn => {
				_type => 'ARStatusList',
				_data => 'p->u.xmlDeleteEntryReturn',
			},
		},
	},
},
AREntryReturn => {
	_min_version => '7.0.0',
	entryId => {
		_type => 'AREntryIdType',
		_data => 'p->entryId',
	},
	status => {
		_type => 'ARStatusList',
		_data => 'p->status',
	},
},
ARXMLEntryReturn => {
	_min_version => '7.0.0',
	outputDoc => {
		_type => 'char *',
		_data => 'p->outputDoc',
	},
	status => {
		_type => 'ARStatusList',
		_data => 'p->status',
	},
},
ARStatusList => {
	_num  => 'p->numItems',
	_list => 'p->statusList',
	_type => 'ARStatusStruct',
},


ARCharMenuList => {
	_num  => 'p->numItems',
	_list => 'p->charMenuList',
	_type => 'ARCharMenuItemStruct',
},
ARCharMenuQueryStruct => {
	schema => {
		_type => 'ARNameType',
		_data => 'p->schema',
	},
	server => {
		_type => 'char[AR_MAX_SERVER_SIZE+1]',
		_data => 'p->server',
	},
	labelField => {
		_type => 'ARInternalId[AR_MAX_LEVELS_DYNAMIC_MENU]',
		_data => 'p->labelField',
	},
	valueField => {
		_type => 'ARInternalId',
		_data => 'p->valueField',
	},
	sortOnLabel => {
		_type => 'ARBoolean',
		_data => 'p->sortOnLabel',
	},
	qualifier => {
		_type => 'ARQualifierStruct',
		_data => 'p->qualifier',
	},
},
ARCharMenuFileStruct => {
	fileLocation => {
		_type => 'unsigned int',
		_data => 'p->fileLocation',
	},
	filename => {
		_type => 'char *',
		_data => 'p->filename',
	},
},
ARCharMenuSQLStruct => {
	server => {
		_type => 'char[AR_MAX_SERVER_SIZE+1]',
		_data => 'p->server',
	},
	labelIndex => {
		_type => 'int[AR_MAX_LEVELS_DYNAMIC_MENU]',
		_data => 'p->labelIndex',
	},
	valueIndex => {
		_type => 'int',
		_data => 'p->valueIndex',
	},
	sqlCommand => {
		_type => 'char *',
		_data => 'p->sqlCommand',
	},
},
ARCharMenuSSStruct => {
	menuName => {
		_type => 'ARNameType',
		_data => 'p->menuName',
	},
	keywordList => {
		_type => 'ARFieldValueList',
		_data => 'p->keywordList',
	},
	parameterList => {
		_type => 'ARFieldValueList',
		_data => 'p->parameterList',
	},
	externList => {
		_type => 'ARQualifierList',
		_data => 'p->externList',
	},
	server => {
		_type => 'char *',
		_data => 'p->server',
	},
	schema => {
		_type => 'char *',
		_data => 'p->schema',
	},
},
ARCharMenuDDStruct => {
	server => {
		_type => 'char[AR_MAX_SERVER_SIZE+1]',
		_data => 'p->server',
	},
	nameType => {
		_type => 'unsigned int',
		_data => 'p->nameType',
	},
	valueFormat => {
		_type => 'unsigned int',
		_data => 'p->valueFormat',
	},
	structType => {
		_type => 'unsigned int',
		_data => 'p->structType',
	},
	_switch  => 'p->structType',
	_map => 'structType',
	_case    => {
		AR_CHAR_MENU_DD_FORM => {
			_type => 'ARCharMenuDDFormStruct',
			_data => 'p->u.formDefn',
		},
		AR_CHAR_MENU_DD_FIELD => {
			_type => 'ARCharMenuDDFieldStruct',
			_data => 'p->u.fieldDefn',
		},
	},
},
ARCharMenuDDFormStruct => {
	schemaType => {
		_type => 'unsigned int',
		_data => 'p->schemaType',
	},
	includeHidden => {
		_type => 'ARBoolean',
		_data => 'p->includeHidden',
		_map  => {
			FALSE => 'false',
			TRUE  => 'true',
		},
	},
},
ARCharMenuDDFieldStruct => {
	fieldType => {
		_type => 'unsigned int',
		_data => 'p->fieldType',
	},
	schema => {
		_type => 'ARNameType',
		_data => 'p->schema',
	},
},
ARQualifierList => {
	_num  => 'p->numItems',
	_list => 'p->qualifierList',
	_type => 'ARQualifierStruct',
},

#ARArchiveInfoStruct => {
#	_min_version => '6.0.0',
#	_switch  => 'p->archiveType',
##	_default =>	'AR_FIELD_REGULAR',
#	_map => [ 'archiveType', {
#		AR_ARCHIVE_NONE     => 0,
#		AR_ARCHIVE_FORM     => 1,
#		AR_ARCHIVE_DELETE   => 2,
#		'AR_ARCHIVE_FORM | AR_ARCHIVE_DELETE' => 3,
#		AR_ARCHIVE_FILE_XML => 4,
#		AR_ARCHIVE_FILE_ARX => 8,
#	} ],
#	_case    => {
#		AR_ARCHIVE_NONE => {
#			_default => 1,
#		},
#		AR_ARCHIVE_FORM => {
#			formName => {
#				_type => 'ARNameType',
#				_data => 'p->u.formName',
#			},
#		},
#		AR_ARCHIVE_DELETE => {
#			formName => {
#				_type => 'ARNameType',
#				_data => 'p->u.formName',
#			},
#		},
#		'AR_ARCHIVE_FORM | AR_ARCHIVE_DELETE' => {
#			formName => {
#				_type => 'ARNameType',
#				_data => 'p->u.formName',
#			},
#		},
#		AR_ARCHIVE_FILE_XML => {
#			dirPath => {
#				_type => 'char*',
#				_data => 'p->u.dirPath',
#			},
#		},
#		AR_ARCHIVE_FILE_ARX => {
#			dirPath => {
#				_type => 'char*',
#				_data => 'p->u.dirPath',
#			},
#		},
#	},
#	archiveType => {
#		_type => 'unsigned int',
#		_data => 'p->archiveType',
#	},
#	enable => {
#		_type => 'unsigned int',
#		_data => 'p->enable',
#		_map => {
#			FALSE => 'false',
#			TRUE  => 'true',
#		},
#	},
##	archiveTime => {
##		_type => 'ARDayStruct',
##		_data => 'p->archiveTime',
##	},
#
#	TmMonthDayMask => {
#		_type => 'long',
#		_data => 'p->archiveTime.monthday',
#	},
#	TmWeekDayMask => {
#		_type => 'long',
#		_data => 'p->archiveTime.weekday',
#	},
#	TmHourMask => {
#		_type => 'long',
#		_data => 'p->archiveTime.hourmask',
#	},
#	TmMinute => {
#		_type => 'unsigned int',
#		_data => 'p->archiveTime.minute',
#	},
#
#	query => {
#		_type => 'ARQualifierStruct',
#		_data => 'p->query',
#	},
#	archiveFrom => {
#		_type => 'ARNameType',
#		_data => 'p->archiveFrom',
#	},
#},
#ARCharMenuItemStruct => {
#	menuLabel => {
#		_type => 'ARNameType',
#		_data => 'p->menuLabel',
#	},
#	_switch  => 'p->menuType',
#	_map => {
#		AR_MENU_TYPE_VALUE  => 'menuValue',
#		AR_MENU_TYPE_MENU   => 'childMenu',
#	},
#	_case    => {
#		AR_MENU_TYPE_VALUE => {
#			menuValue => {
#				_type => 'char *',
#				_data => 'p->u.menuValue',
#			},
#		},
#		AR_MENU_TYPE_MENU => {
#			childMenu => {
##				_type => 'ARCharMenuStruct*',
##				_data => 'p->u.childMenu',
#				_type => 'ARCharMenuList',
#				_data => 'p->u.childMenu->u.menuList',
#			},
#		},
#	},
#},
#ARCharMenuStruct => {
#	_switch  => 'p->menuType',
#	_map => 'CharMenuTypeMap',
#	_case    => {
#		AR_CHAR_MENU_LIST => {
#			_type => 'ARCharMenuList',
#			_data => 'p->u.menuList',
#		},
#		AR_CHAR_MENU_QUERY => {
#			_type => 'ARCharMenuQueryStruct',
#			_data => 'p->u.menuQuery',
#		},
#		AR_CHAR_MENU_FILE => {
#			_type => 'ARCharMenuFileStruct',
#			_data => 'p->u.menuFile',
#		},
#		AR_CHAR_MENU_SQL => {
#			_type => 'ARCharMenuSQLStruct',
#			_data => 'p->u.menuSQL',
#		},
#		AR_CHAR_MENU_SS => {
#			_type => 'ARCharMenuSSStruct',
#			_data => 'p->u.menuSS',
#		},
#		AR_CHAR_MENU_DATA_DICTIONARY => {
#			_type => 'ARCharMenuDDStruct',
#			_data => 'p->u.menuDD',
#		},
#	},
#},


#ARInternalIdList => {
#	_num  => 'p->numItems',
#	_list => 'p->internalIdList',
#	_type => 'ARInternalId',
#},
#ARWorkflowConnectList => {
#	_num  => 'p->numItems',
#	_list => 'p->workflowConnectList',
#	_type => 'ARWorkflowConnectStruct',
#},
#ARWorkflowConnectStruct => {
#	_switch => 'p->type',
#	_case    => {
#		AR_WORKFLOW_CONN_NONE => {
#			_default => 1,
#		},
#		AR_WORKFLOW_CONN_SCHEMA_LIST => {
#			schemaList => {
#				_type => 'ARNameList',
#				_data => 'p->u.schemaList',
#			},
#		},
#	},
#},
#ARReferenceStruct => {
#	label => {
#		_type => 'char *',
#		_data => 'p->label',
#	},
#	description => {
#		_type => 'char *',
#		_data => 'p->description',
#	},
#	type => {
#		_type => 'unsigned int',
#		_data => 'p->type',
#	},
#
#	_switch => 'p->reference.dataType',
#	_map => 'dataType',
#	_case => {
#		ARREF_DATA_ARSREF => {
#			'name' => {
#				_type => 'ARNameType',
#				_data => 'p->reference.u.name',
#			},
#		},
#		ARREF_DATA_EXTREF => {
#			'extRef' => {
#				_type => 'ARExtReferenceStruct',
#				_data => 'p->reference.u.extRef',
#			},
#		},
#	},
#},
#ARExtReferenceStruct => {
#	permittedGroups => {
#		_type => 'ARInternalIdList',
#		_data => 'p->permittedGroups',
#	},
#	value => {
#		_type => 'ARValueStruct',
#		_data => 'p->value',
#	},
#},


# Structures from "ardbc.h":
#ARVendorFieldList => {
#	_num  => 'p->numItems',
#	_list => 'p->fieldList',
#	_type => 'ARVendorFieldStruct',
#},
#ARVendorFieldStruct => {
#	fieldName => {
#		_type => 'ARNameType',
#		_data => 'p->fieldName',
#	},
#	fieldId => {
#		_type => 'ARInternalId',
#		_data => 'p->fieldId',
#	},
#	dataType => {
#		_type => 'int',
#		_data => 'p->dataType',
#	},
#},


);




# perl C:\usr\perl_install\5.8.8\ARSperl\TS\printStructTemplate.pl AR...
#
#	x => {
#		_type => '',
#		_data => '',
#	},

# s/.*/$& => {\n\t_type => '',\n\t_data => 'p->u.',\n},/


%TEMPLATES = (
	_copy => [
		'ARValueStruct'   => 'rev_%T( ctrl, h, k, "dataType", &(%L) )',
		'ARValueStruct\*' => '%L = MALLOCNN(sizeof(%B)); rev_%B( ctrl, h, k, "dataType", %L )',
		'AR\w+'   => 'rev_%T( ctrl, h, k, &(%L) )',
		'AR\w+\*' => '%L = MALLOCNN(sizeof(%B)); rev_%B( ctrl, h, k, %L )',
		'(int|long|unsigned\s+int|unsigned\s+long)' => '%L = SvIV(%R)',
		'(float|double)'                            => '%L = SvNV(%R)',
		'unsigned\s+char'                           => '%L = (char) SvIV(%R)',
		'char\s*\*' => '%L = strdup( SvPV_nolen(%R) )',
		'char\[.+]' => 'strncpy( %L, SvPV_nolen(%R), sizeof(%L) )',
		'ARInternalId\[(\w+)\]' => 'copyUIntArray( %1, %L, %R )',
		'int\[(\w+)\]'          => 'copyIntArray( %1, %L, %R )',
	],
	_perl => [
		'ARInternalId\[\]'     => '*** unknown ***',     # ???
		'ARInternalId\[\w+\]'  => '*** unknown ***',     # ???
		'int\[\w+\]'           => '*** unknown ***',     # ???
		'unsigned\s+char'      => '%L = newSVnv( %R )',  # ???
		
		'AR\w+'   => '%L = perl_%T( ctrl, &(%R) )',
		'AR\w+\*' => '%L = perl_%B( ctrl, %R )',
		'(int|long|unsigned\s+int|unsigned\s+long)' => '%L = newSViv( %R )',
		'(float|double)'                            => '%L = newSVnv( %R )',
		'char\s*\*' => '%L = newSVpv( %R, 0 )',
		'char\[.+]' => '%L = newSVpv( %R, 0 )',
	],
);



#print evalTemplate( 'COPY', 'char[10]', 'p->charVal', 'buffer' ), "\n";
#print evalTemplate( 'COPY', 'unsigned char', 'p->unique', 'buffer' ), "\n";


#ARIntegerLimitsStruct intLimits;
#ARRealLimitsStruct    realLimits;
#ARCharLimitsStruct    charLimits;
#ARDiaryLimitsStruct   diaryLimits;
#AREnumLimitsStruct    enumLimits;
#AREnumLimitsStruct    maskLimits;
#ARAttachLimitsStruct  attachLimits;
#ARTableLimitsStruct   tableLimits;
#ARColumnLimitsStruct  columnLimits;
#ARDecimalLimitsStruct decimalLimits;
#ARViewLimits          viewLimits;
#ARDisplayLimits       displayLimits;
#ARDateLimitsStruct    dateLimits;
#ARCurrencyLimitsStruct currencyLimits;



