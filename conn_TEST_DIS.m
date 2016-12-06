clear all;

study='DIS_MVPA';
subjs={'SAX_DIS_05'};
sessions={[6 7 8 9]};
an={'roi'};

conn_BATCH_setup_DIS(study, subjs, sessions, an);
conn_BATCH_firstlevel_DIS(study,'conn_DIS_MVPA_SAX_DIS_05_roi',{'corr'},1)

