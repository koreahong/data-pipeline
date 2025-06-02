"""
This file has been generated from dag_runner.j2
"""
from airflow import DAG
from openmetadata_managed_apis.workflows import workflow_factory

workflow = workflow_factory.WorkflowFactory.create("/opt/airflow/dag_generated_configs/0047440a-99a8-4b66-95f1-774ed54775d6.json")
workflow.generate_dag(globals())
dag = workflow.get_dag()