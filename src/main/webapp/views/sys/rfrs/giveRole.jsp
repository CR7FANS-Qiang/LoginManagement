<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/commons/global.jsp" %>

<body>	
	<script type="text/javascript">
    var roleListDataGrid;
    $(function() {
        roleListDataGrid = $('#roleListDataGrid').datagrid({
            url : '${path}/pages/role/dataGridByFunctionId',
            striped : true,
            rownumbers : true,
            pagination : true,
            singleSelect : false,
            autoRowHeight:false,
            idField : 'id',
            sortName : 'a.inserttime',
            sortOrder : 'desc',
            fit : true,
            autoRowHeight: false,
            fitColumns:true,
            fix:false,
            pageSize : 20,
            pageList : [ 10, 20, 30, 40, 50, 100, 200, 300, 400, 500 ],
            columns: [[
            { 
           	   field:'ck',checkbox:true
           	},
           	{
                width : '10%',
                title : '主键',
                field : 'id',
                sortable : true,
                align : 'center',
            	hidden : true
            } , 
			{
                width : '20%',
                title : '角色名称',
                field : 'name',
                sortable : false,
                align : 'center',
                hidden : false
            },
            {
                width : '50%',
                title : '所属系统',
                field : 'systemName',
                sortable : false,
                align : 'center',
                hidden : false
            }
			]],
            onLoadSuccess:function(data){
            	
            }
//             toolbar : '#addPurchOrderListToolbar'
        });
    });
    
    function addDetail(cid){
    	var checkedItems = roleListDataGrid.datagrid('getChecked');
    	if(checkedItems.length == 0){
    		easyui_alert('请至少选择一条记录！');
    		return false;
    	}
    	var ids = [];
    	$.each(checkedItems, function(index, item){    
    		ids.push(item.id); 
    	});
    	$('#idsGive').val(ids);
    	$('#purchInvoiceAddForm').form('submit',{
            url : '${path}/pages/role/addRFRS',
            onSubmit : function() {
                
            	return true;
            },
            success : function(result) {
                progressClose();
                result = $.parseJSON(result);
                if (result.success) {
                	detailDataGrid.datagrid('reload');
                	$("#"+cid).dialog("close");
    				$("#"+cid).dialog("destroy");
                } else {
                	easyui_error(result.msg);
                }
            }
        });
    }
    
    function roleListSearchFun() {
        roleListDataGrid.datagrid('load', $.serializeObject($('#roleListSearchForm')));
    }
    
    function roleListCleanFun() {
        $('#roleListSearchForm input').val('');
        roleListDataGrid.datagrid('load', $.serializeObject($('#roleListSearchForm')));
    }
    
</script>
    <div id="orderLay" class="easyui-layout" data-options="fit:true,border:true,title:'角色关联功能列表'">
           <div data-options="region:'north',border:false" style="width:100%;height: 50px; overflow: hidden;background-color: #fff">
	        <form id="purchInvoiceAddForm" method="post">
	        	<input type="hidden" id="functionId" name="functionId" value="${function.id}" />
	        	<input type="hidden" id="idsGive" name="ids" value=""/>
	        </form>
	        <form id="roleListSearchForm">
	            <table>
	                <tr>
	                    <th>角色名称:</th>
	                    <td>
	                    	<input id="roleList_name" name="name" placeholder="请输入角色名称"/>
	                    </td>
	                    <td width="300">
		                    <a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true" onclick="roleListSearchFun();">查询</a>
		                    <a href="javascript:void(0);" class="easyui-linkbutton" data-options="iconCls:'icon-cancel',plain:true" onclick="roleListCleanFun();">清空</a>
	                    </td>                   
	                </tr>
	            </table>
	        </form>
	    </div>
        <div data-options="region:'center',fit:true,border:true" style="height:95%;">
            <table id="roleListDataGrid" data-options="border:false"></table>
        </div>
    </div>
    <div id="addPurchOrderListToolbar" style="display: none;">
    </div>
</body>
