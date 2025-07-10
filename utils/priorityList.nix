# A pririty list is a list that looks like this:
# priorityList = [
# {priority = 1; value = 1;},
# {priority = 2; value = 2;},
# {priority = 3; value = 3;},
# ];
# It must have a unique priority to avoid undefined behavior.
{lib}: let
  inherit (lib) map sort concatStringsSep unique length;
  inherit (builtins) toString;
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
    assertion = (priorityList |> map (item: item.priority) |> unique |> length) == (priorityList |> length);
    message = "Priority list must have unique priorities. Duplicates found. The priorities are: ${priorityList |> map (i: toString i.priority) |> concatStringsSep ", "}";
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
