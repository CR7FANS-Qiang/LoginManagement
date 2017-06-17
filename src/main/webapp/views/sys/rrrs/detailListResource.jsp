<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/commons/global.jsp" %>
<!DOCTYPE html>
<script type="text/javascript">
	var oldIndex;
    var detailDataGrid;
    var organizationTree;
    $(function() {
    	var roleId = '${role.id}';
    	var systemId = '${systemId}';
    	
    	searchResourceTreeBySystemId(systemId,roleId);
    	
        detailDataGrid = $('#detailDataGrid').datagrid({
            url : '${path}/pages/resource/dataGridByRoleId?roleId='+roleId,
            striped : true,
            rownumbers : true,
            pagination : true,
            singleSelect : false,
            idField : 'id',
            sortName : 'a.inserttime',
            sortOrder : 'desc',
            fit : true,
            fitColumns : true,
            fix : false,
            autoRowHeight : false,
            pageSize : 20,
            pageList : [ 10, 20, 30, 40, 50, 100, 200, 300, 400, 500 ],
            columns: [[
            { 
           	   field : 'ck', checkbox : true
           	},
           	{field : 'name',title : '资源名称',width : '13%'}, 
            {field : 'link',title : '资源路径',width : '20%'}, 
            {field : 'type',title : '资源类型',width : '7%', 
          	  formatter : function(value, row, index) {
         			switch (value) {
			             case 1:
			                 return '菜单';
			             case 2:
			                 return '接口';
			        }
  		  	  }
            }, 
            {field : 'parentResourceId',title : '上级资源ID',width : '10%',hidden : true}, 
            {field : 'status',title : '状态',width : '4%',
		          formatter : function(value, row, index) {
		              switch (value) {
		              case 1:
		                  return '在用';
		              case 2:
		                  return '停用';
		              }
		          }
			  },
			  {field : 'systemName',title : '所属系统',width : '20%'},
			  {field : 'componentName',title : '所属组件',width : '10%'}
			]],
			onDblClickRow:function(index, rowData){
				if(oldIndex != null && oldIndex != undefined){
					$('#detailDataGrid').datagrid('endEdit', oldIndex);
				}
				oldIndex = index;
				$('#detailDataGrid').datagrid('beginEdit', index);
			},
			onClickRow:function(rowIndex, rowData){
				$('#detailDataGrid').datagrid('endEdit', oldIndex);
			},
            onLoadSuccess:function(data){
                $('.accountRoleRS-easyui-linkbutton-edit').linkbutton({text:'解除关联',plain:true,iconCls:'icon-del'});
            },
            toolbar : '#detailToolbar'
        });
    });

    function addRRRSFun() {
    	var roleId = '${role.id}';
    	var systemId = '${systemId}';
    	var url="${path}/pages/resource/roleGiveResource?roleId="+roleId+"&systemId="+systemId;//?invoiceId="+'${purchInvoice.id}'+"&billType=1
    	
        openEditDialog(url, 500, 900, detailDataGrid, function(cid) {
			addDetail(cid);
		}).dialog('open').dialog('setTitle', '添加资源关联');
    }
    
    function detailDeleteFun() {
    	var checkedItems = detailDataGrid.datagrid('getChecked');
    	if(checkedItems.length == 0){
    		easyui_alert('请至少选择一条记录！');
    		return false;
    	}
    	var ids = '';
    	$.each(checkedItems, function(index, item){    
    		ids+=item.id+',';    		
    	});
    	$('#idsDetail').val(ids);
        progressLoad();
        $.post('${path}/pages/resource/deleteRRRS', {
            ids : ids,
            roleId :'${role.id}'
        }, function(result) {
        	progressClose();
            if (result.success) {
            	easyui_alert(result.msg);
            	for(var i = checkedItems.length; i > 0; i--){
            		var index = detailDataGrid.datagrid('getRowIndex', checkedItems[i-1]);
            		detailDataGrid.datagrid('deleteRow', index);
            	}
                detailDataGrid.datagrid('reload');
                organizationTree.tree('reload');
            }
            progressClose();
        }, 'JSON');
    }

    function changeRealPrice() {
    }
    
    function detailSearchFun() {
        detailDataGrid.datagrid('load', $.serializeObject($('#detailSearchForm')));
    }
    
    function detailCleanFun() {
        $('#detailSearchForm input').val('');
        
        $('#detailSearchForm select').combobox({
        	onLoadSuccess: function (row, data) {
        		$(this).combobox('setValue', '');
        	}
        });
        detailDataGrid.datagrid('load', {});
    }
    
    function searchResourceTreeBySystemId(systemId,roleId){
    	organizationTree = $('#organizationTree').tree({
            url : '${path }/pages/resource/treeByRoleId',
            queryParams: {
            	systemId: systemId,
            	roleId: roleId
        	},
        	method : "post",
            parentField : 'parentResourceId',
            textField : 'name',
            lines : true,
            onClick : function(node) {
//                 dataGrid.datagrid('load', {
//                    organizationId: node.id
//                });
            }
        });
    }
</script>
</head>
<body>	
    <div class="easyui-layout" data-options="fit:true,border:true,title:'角色关联列表'">
			<div data-options="region:'north',fit:false,border:false,title:'查询条件',hideCollapsedContent:false" style="height:70px;overflow: hidden;padding:1px;background-color: #fff">
	    		<form id="detailSearchForm">
	    			<input id='roleId' name="roleId" value='${role.id}' type="hidden" />
	    			<input id='systemId' name="systemId" value='${systemId}' type="hidden" />
	    			<input type="hidden" id="idsDetail" name="ids" value="" />
	    			<div class="search_condition">
	    				<p>
							<b>当前角色：</b>
	                		<b style="color: red;">${role.name}</b>
						</p>
    					<p>
							<b>资源名称</b>
	                		<input id="resource_query" name="name" type="text" placeholder="请输入资源名称" class="easyui-validatebox span2" maxlength="32" value=""/>
						</p>
    					<%-- <p>
							<b>所属系统</b>
	                		<select id="systemId_query" name="systemId" class="easyui-combobox" data-options="width:120,height:26,editable:false,panelHeight:'140px'">
			              		<option value="">-请选择-</option>
				                <c:forEach items="${systemList}" var="system">
									<option value="${system.id}">${system.name}</option>
								</c:forEach>
							 </select>
						</p> --%>
						<p class="btnSear">
		                    <a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true" onclick="detailSearchFun();">查询</a>
		                    <a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-cancel',plain:true" onclick="detailCleanFun();">清空</a>
		                </p>
					</div>
	    		</form>
    		</div>
        <div data-options="region:'center',border:false">
        	<form id="detailListForm" method="post">
        	</form>
            <table id="detailDataGrid" data-options="fit:true,border:false"></table>
        </div>
        <div data-options="region:'west',border:true,split:false,title:'组织机构'"  style="width:240px;overflow: true; ">
		    <ul id="organizationTree"  style="width:160px;margin: 10px 10px 10px 10px"></ul>
   	 	</div>
    </div>
    <div id="detailToolbar" style="display: none;">
        	<a onclick="addRRRSFun();" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:true,iconCls:'icon-add'">关联资源</a>
            <a onclick="detailDeleteFun();" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:true,iconCls:'icon-line'">解除关联</a>
            <a onclick="changeRealPrice();" href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:true,iconCls:'icon-filter'">刷新</a>
    </div>