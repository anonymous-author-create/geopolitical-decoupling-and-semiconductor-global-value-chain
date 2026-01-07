****************************************Basic setting**************************************************

clear all

global Path "" ///Set the file path of panel data

cd $Path

*****************************************Modelling****************************************************

global controls Leverage Roa RD Age Asset

use "Panel_data.dta", clear


** Table 1. Effects of geopolitical decoupling on firm operating costs

reghdfe ln_y treatafter, absorb(Stkcd qdate) vce(cluster Stkcd)

reghdfe ln_y treatafter $controls, absorb(Stkcd qdate) vce(cluster Stkcd)


** Figure 1. Dynamic effects of the Entity List on firms' operating costs

  forvalues l = 0/20 {
        gen L`l'event = q_diff ==`l' //after
		label variable L`l'event "`l' quarter(s) after"
    }
  forvalues l = 1/8 {
        gen F`l'event = q_diff == -`l' //before
		label variable F`l'event "`l' quarter(s) before"
    }

  replace F1event = 0
  reghdfe ln_y L*event F*event $controls, absorb(Stkcd qdate) vce(cluster Stkcd) 
  estimates store DD_LP 
  
    event_plot     DD_LP  ,    ///
    stub_lag( L#event    )       ///
    stub_lead(F#event    )       ///
        together noautolegend             ///
        plottype(scatter) ciplottype(rspike) alpha(0.1)                                                                       ///
            lag_opt1(msymbol(Oh) msize(medium) mcolor(red) )    ///
            lag_ci_opt1(lpattern(dash) color(red) lwidth(medium))  ///
		graph_opt( ///
            title("{fontface Times New Roman:Operating Cost}") ///
            xtitle("{fontface Times New Roman:Relative Quarter}") ///
            ytitle("{fontface Times New Roman:Effect}") ///
            xlabel(-8(1)20, labsize(medium) ) ///
            ylabel(, angle(0) labsize(medium)  format(%03.2f)) ///
            xline(-1, lcolor(gs8) lpattern(dash)) ///
            yline(0, lcolor(gs8)) ///
			legend(off) ///
            graphregion(color(white)) ///
            scheme(s1mono) ///
        )
		
							  
** Table 2. Effects of geopolitical decoupling on semiconductor firms' acquisition of financial resources and outward investment

reghdfe ln_funds_borrowed treatafter $controls, absorb(Stkcd qdate) vce(cluster Stkcd)

reghdfe ln_invest treatafter $controls, absorb(Stkcd qdate) vce(cluster Stkcd)


** Table 3. Effects of geopolitical decoupling on operating costs across semiconductor value chain segments

gen materials = 1 if Emerging_Industries_ID == 8
replace materials = 0 if materials ==.
label variable materials "Firm engaged in semiconductor materials"

gen electronic_component = 1 if Emerging_Industries_ID == 10
replace electronic_component = 0 if electronic_component ==.
label variable electronic_component "Firm engaged in semiconductor electronic components"

gen equipment = 1 if Emerging_Industries_ID == 12
replace equipment = 0 if equipment ==.
label variable equipment "Firm engaged in semiconductor equipments"

gen treatafterMaterials = treatafter * materials
gen treatafterComponent = treatafter * electronic_component
gen treatafterEquipment = treatafter * equipment

reghdfe ln_y treatafter  $controls if equipment == 1, absorb(Stkcd qdate) vce(cluster Stkcd)

reghdfe ln_y treatafter  $controls if materials == 1, absorb(Stkcd qdate) vce(cluster Stkcd)

reghdfe ln_y treatafter  $controls if electronic_component == 1, absorb(Stkcd qdate) vce(cluster Stkcd)


** Table 4. Effects of geopolitical decoupling on access to external economic resources and outward investment across semiconductor value chain segments

reghdfe ln_funds_borrowed treatafter  $controls if equipment == 1, absorb(Stkcd qdate) vce(cluster Stkcd)

reghdfe ln_funds_borrowed treatafter  $controls if materials == 1, absorb(Stkcd qdate) vce(cluster Stkcd)

reghdfe ln_funds_borrowed treatafter  $controls if electronic_component == 1, absorb(Stkcd qdate) vce(cluster Stkcd)

reghdfe ln_invest treatafter  $controls if equipment == 1, absorb(Stkcd qdate) vce(cluster Stkcd)

reghdfe ln_invest treatafter  $controls if materials == 1, absorb(Stkcd qdate) vce(cluster Stkcd)

reghdfe ln_invest treatafter  $controls if electronic_component == 1, absorb(Stkcd qdate) vce(cluster Stkcd)


** Appendix Table 6. Descriptive analysis

preserve

format ln_y ln_funds_borrowed ln_invest $controls %9.4f

outreg2 using "Descriptive analysis.doc", replace sum(log) ///
        keep (ln_y ln_funds_borrowed ln_invest treatafter $controls) ///
		title(Descriptive analysis)
restore


** Appendix Table 7. Heterogeneity robust check

reghdfe ln_y treatafterEquipment treatafterMaterials treatafterComponent $controls, absorb(Stkcd qdate) vce(cluster Stkcd)

reghdfe ln_funds_borrowed treatafterEquipment treatafterMaterials treatafterComponent $controls, absorb(Stkcd qdate) vce(cluster Stkcd)

reghdfe ln_invest treatafterEquipment treatafterMaterials treatafterComponent $controls, absorb(Stkcd qdate) vce(cluster Stkcd)						  
