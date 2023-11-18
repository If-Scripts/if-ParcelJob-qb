local Translations = {
    error = {
        ["cancled"] = "Canceled",
        ["no_car"] = "You have no Car!",
        ["not_enough"] = "Not Enough Money (%{value} required)",
        ["too_far"] = "You are too far away from the drop-off point",
        ["early_finish"] = "Due to early finish (Completed: %{completed} Total: %{total}), your deposit will not be returned.",
        ["never_clocked_on"] = "You never clocked on!",
        ["all_occupied"] = "All parking spots are occupied",
        ["job"] = "You must get the job from the job center",
    },
    success = {
        ["clear_routes"] = "Cleared users routes they had %{value} routes stored",
        ["pay_slip"] = "You got $%{total}, your payslip %{deposit} got paid to your bank account!",
    },
    target = {
        ["talk"] = 'Talk to Boss',
        ["grab_parcel"] = "Grab Parcel",
        ["keep_parcel"] = "Keep Parcel In Car",
    },
    menu = {
        ["header"] = "Parcel Main Menu",
        ["collect"] = "Collect Paycheck",
        ["return_collect"] = "Return car and collect paycheck here!",
        ["route"] = "Request Route",
        ["request_route"] = "Request a Parcel Collecting Route",
    },
    info = {
        ["payslip_collect"] = "[E] - Payslip",
        ["payslip"] = "Payslip",
        ["not_enough"] = "You have not enough money for the deposit.. Deposit costs are $%{value}",
        ["deposit_paid"] = "You have paid $%{value} deposit!",
        ["no_deposit"] = "You have no deposit paid on this vehicle..",
        ["car_returned"] = "car returned, collect your payslip to receive your pay and deposit back!",
        ["parcel_left"] = "There are still %{value} parcels left!",
        ["parcel_still"] = "There is still %{value} parcel over there!",
        ["all_parcel"] = "Parcels are Collected From This Location, proceed to the next location!",
        ["depot_issue"] = "There was an issue at the depot, please return immediately!",
        ["done_working"] = "You are done working! Go back to the depot.",
        ["started"] = "You have started working, location marked on GPS!",
        ["grab_parcel"] = "[E] Grab a  parcel",
        ["stand_grab_parcel"] = "Stand here to grab a  parcel.",
        ["keep_parcel"] = "[E] To Keep Parcel In Car..",
        ["progressbar"] = "Putting parcel in Car..",
        ["parcel_in_car"] = "Put the parcel in your car..",
        ["stand_here"] = "Stand here..",
        ["found_crypto"] = "You found a cryptostick on the floor",
        ["payout_deposit"] = "(+ $%{value} deposit)",
        ["store_car"] =  "[E] - Store parcel car",
        ["get_car"] =  "[E] - parcel car",
        ["picking_parcel"] = "Grabbing parcel..",
        ["talk"] = "[E] Talk to Boss",
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
