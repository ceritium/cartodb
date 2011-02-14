

    var requests_queue = new loaderQueue();


    $(document).ready(function(){
      $("table#cDBtable").cDBtable(
        'start',{
          getDataUrl: '/api/json/tables/'+table_id,
          resultsPerPage: 50,
          reuseResults: 100,
          total: 5000
        }
      );
      $('p.session a, a.logo').click(function(){window.location.href = $(this).attr('href');});
    });
    
    
    
    /*============================================================================*/
  	/* Use unique  */
  	/*============================================================================*/
    function createUniqueId() {
      var uuid= '';
      for (i = 0; i < 32; i++) {
      	uuid += Math.floor(Math.random() * 16).toString(16);
      }
      return uuid;
    }


    
    /*============================================================================*/
  	/* Sanitize texts  */
  	/*============================================================================*/
    function sanitizeText(str) {
      return str.replace(/[^a-zA-Z 0-9 _]+/g,'').replace(' ','_').toLowerCase();
    }
    
    
    
