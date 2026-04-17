/* ===========================================================================
Project: LSE Applied Econometrics Coursework
Author: Varun Vinod Rao
Description: Difference-in-Differences (DID) estimation with Fixed Effects.
             Includes data transformations, primary regressions, robustness 
             checks, and placebo tests.
=========================================================================== */

* ============================================================================
* (I) Data Exploration & Functional Form (Inverse Hyperbolic Sine Transformation)
* ============================================================================

* 1.1 Analyze raw distribution of the dependent variable (Total Birds Counted)
histogram num_tot, frequency ///
    title("Distribution of Total Birds Counted") ///
    xtitle("Total Bird Count") ///
    ytitle("Frequency")

* 1.2 Analyze IHS-transformed distribution to handle skewness
histogram ihs_num_tot, frequency ///
    title("Distribution of Total Birds Counted - IHS Transformation") ///
    xtitle("Total Bird Count - IHS Transformation") ///
    ytitle("Frequency")

* Note: IHS-transformed variables are utilized due to the highly skewed 
* distribution of the linear dependent variable.

* ============================================================================
* (II) Difference-in-Differences (DID) Model via Fixed Effects
* ============================================================================

* 2.1 Declare panel data structure (Circle ID and Year)
xtset circle_id year  

* 2.2 Primary Specification: Fixed Effects regression controlling for 
* circle-specific and year-specific unobservables, with clustered standard errors.

* Model A: Impact of Shale Gas Extraction (any_shale)
xtreg ihs_num_tot any_shale ihs_total_effort_counters Min_temp Max_temp Max_wind ///
    Max_snow Min_snow latitude longitude ag_land_share past_land_share ///
    dev_share_broad i.year, fe vce(cluster circle_id)

* Export regression output
outreg2 using regressions.doc, replace 

* Model B: Impact of Wind Turbines (any_turbine)
xtreg ihs_num_tot any_turbine ihs_total_effort_counters Min_temp Max_temp Max_wind ///
    Max_snow Min_snow latitude longitude ag_land_share past_land_share ///
    dev_share_broad i.year, fe vce(cluster circle_id)

outreg2 using regressions.doc, append 

* ============================================================================
* (III) Robustness Checks
* ============================================================================

* 3.1 Placebo Test: Generating a lead treatment variable to test parallel trends
gen lead_any_shale = F.any_shale

xtreg ihs_num_tot lead_any_shale ihs_total_effort_counters Min_temp Max_temp ///
    Max_wind Max_snow Min_snow latitude longitude ag_land_share past_land_share ///
    dev_share_broad i.year, fe vce(cluster circle_id)

outreg2 using results.doc, replace 

* 3.2 Alternative Specification (Intensity of Treatment): Number of wells vs. Binary
xtreg ihs_num_tot shalewells_num ihs_total_effort_counters Min_temp Max_temp ///
    Max_wind Max_snow Min_snow latitude longitude ag_land_share past_land_share ///
    dev_share_broad i.year, fe vce(cluster circle_id)

outreg2 using regressions.doc, append

* 3.3 Alternative Functional Form: Linear dependent variable instead of IHS
xtreg num_tot any_shale ihs_total_effort_counters Min_temp Max_temp Max_wind ///
    Max_snow Min_snow latitude longitude ag_land_share past_land_share ///
    dev_share_broad i.year, fe vce(cluster circle_id)

outreg2 using regressions.doc, append 

* ============================================================================
* (IV) Confounder Test
* ============================================================================

* 4.1 Testing if human population dynamics are driving the results
xtreg ihs_num_tot any_shale ln_pop ihs_total_effort_counters Min_temp Max_temp ///
    Max_wind Max_snow Min_snow latitude longitude ag_land_share past_land_share ///
    dev_share_broad i.year, fe vce(cluster circle_id)

outreg2 using results.doc, append
