$(document).ready(function() {
  initializeAuditionGroups();
});

function initializeAuditionGroups() {
  $("table#audition_groups").
    on('click', 'button.toggle-group', manageAuditionEllipsis).
    on('click', 'button.single-remove', removeSingleAudition).
    on('click', 'button.block-remove', removeBlockAudition);
}

function manageAuditionEllipsis(e) {
  e.preventDefault();
  var hide = $(this).is('.hide-group');
  var thead = $(this).closest('thead')
  var tbody = thead.next();
  tbody.find('.ellipsis').toggle(hide);
  tbody.find('.condensed').toggle(!hide);
  thead.find('.show-group').toggle(hide);
  thead.find('.hide-group').toggle(!hide);
}

function removeSingleAudition(e) {
  if (confirm('This audition will be deleted. There is no undo. Are you sure?')) {
    var index = $(this).data('index');
    var action = $(this).closest('form').attr('action');
    var tr = $(this).closest('tr');
    var thead = tr.closest('tbody').prev();
    var audition_id = tr.data('audition-id');
    e.preventDefault();
    send_destroy(action, [audition_id], index);
  }
}

function removeBlockAudition(e) {
  var action = $(this).closest('form').attr('action');
  var thead = $(this).closest('thead');
  var tbody = thead.next();
  var audition_ids = tbody.find('tr').map(function() { return $(this).data('audition-id'); });
  if (confirm('These '+audition_ids.length+' auditions will be deleted. There is no undo. Are you sure?')) {
    e.preventDefault();
    send_destroy(action, $.makeArray(audition_ids), null);
  }
}

// Make a destroy call to remove the passed ids
function send_destroy(action, ids, index) {
  $.ajax({
    url: action,
    data: {destroy_ids: ids, index: index},
    type: 'PUT',
    dataType: 'script'
  });
}
