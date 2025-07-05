# A pririty list is a list that looks like this:
# priorityList = [
# {priority = 1; value = 1;},
# {priority = 2; value = 2;},
# {priority = 3; value = 3;},
# ];
# It must have a unique priority to avoid undefined behavior.
{lib}:
with lib; let
  # Given a priority list, this will return a list of values sorted by priority.
  # With smallest priority first.
  # To make a string from this can do something like this:
  # concatedString = priorityList |> priorityListToList |> concatStringsSep "\n";
  priorityListToList = priorityList: priorityList |> sort (a: b: a.priority < b.priority) |> map (item: item.value);
in {
  inherit priorityListToList;

  # This is expected to be used as element in assertions list like this:
  # assertions = [
  #   ...
  #   validatePriorityList cfg.items
  #   ...
  # ];
  validatePriorityList = priorityList: {
    assertion = let
      priorities = map (item: item.priority) priorityList;
      uniquePriorities = unique priorities;
    in
      length priorities == length uniquePriorities;

    message = let
      priorities = map (item: item.priority) priorityList;

      # Find duplicates with their values
      duplicateInfo =
        filter
        (info: info.count > 1)
        (map (p: {
          priority = p;
          count = count (x: x == p) priorities;
          values = map (item: item.value) (filter (item: item.priority == p) priorityList);
        }) (unique priorities));

      formatDuplicate = info: "priority ${toString info.priority} (used by: ${concatStringsSep ", " (map (v: "\"${v}\"") info.values)})";
    in ''
      myModule.priorityString.items: Duplicate priorities found:
      ${concatStringsSep "\n  " (map formatDuplicate duplicateInfo)}
    '';
  };

  # Convinience function to convert a priority list to a string by \n concats.
  priorityListToString = priorityList: priorityList |> priorityListToList |> concatStringsSep "\n";

  # Given a starting priority, this will convert a list of values to a priority list.
  # With smallest priority first.
  listToPriorityList = startingPriority: list:
    list
    |> lib.imap0 (i: item: {
      priority = startingPriority + i;
      value = item;
    });
}
